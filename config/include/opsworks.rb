namespace :opsworks do
  desc 'List stacks'
  task :list_stacks do

    logger.notice 'Available stacks: '
    begin
      response = AWS_OPSWORKS.describe_stacks
    rescue Exception => e
      logger.aborting "Exception raised: #{e}"
      abort
    else
      response[:stacks].each { |stack| logger.info stack.values_at(:name, :stack_id).join(', ') } 
    end
  end

  desc 'List layers'
  task :list_layers do
    set(:mystack, Capistrano::CLI.ui.ask("What stack do you want layer details for: "))
    begin
      response = AWS_OPSWORKS.describe_layers(options = {:stack_id => "#{mystack}"})
      response[:layers].each { |layer| logger.info layer.values_at(:name, :layer_id).join(', ') } 
    rescue Exception => e
      logger.aborting "Exception raised: #{e}"
      abort
    end
  end

  desc 'Run deployment command'
  task :cmd do
    list_stacks

    set(:mystack, Capistrano::CLI.ui.ask("What stack do you want to run the command on: "))
    set(:mycmd, Capistrano::CLI.ui.ask("What command do you want to run: "))
    deploy_options = {}
    deploy_options[:command]  = {name:"#{mycmd}"}
    deploy_options[:comment]  = "cap opsworks:cmd from '#{Socket.gethostname}'"
    deploy_options[:stack_id] = "#{mystack}"

    logger.notice "Running #{mycmd} for #{mystack.upcase}"
    begin
      AWS_OPSWORKS.create_deployment deploy_options
    rescue Exception => e
      logger.aborting "Caught exception: #{e}"
      abort
    else
      logger.notice "Success!"
    end
  end

  desc 'Create an instance'
  task :create_instance do
    list_stacks
    list_layers

    set(:mystack, Capistrano::CLI.ui.ask("What stack do you want to launch the instance in: "))
    set(:mylayer, Capistrano::CLI.ui.ask("What layer: "))
    set(:myinstancetype, Capistrano::CLI.ui.ask("What instance type: "))

    hostname_options = {}
    hostname_options[:layer_id] = "#{mylayer}"

    # get hostname suggestion
    begin
      response = AWS_OPSWORKS.get_hostname_suggestion hostname_options
      myhostname = response[:hostname]
    rescue Exception => e
      logger.aborting "Caught exception: #{e}"
      abort
    end

    instance_options = {}
    instance_options[:stack_id]      = "#{mystack}"
    instance_options[:hostname]      = "#{myhostname}"
    instance_options[:layer_ids]     = ["#{mylayer}"]
    instance_options[:instance_type] = "#{myinstancetype}"

    logger.notice "Launching instance"
    begin
      out = AWS_OPSWORKS.create_instance instance_options
      my_instanceid = out[:instance_id]

      instanceid_options = {}
      instanceid_options[:instance_id] = "#{my_instanceid}"
    rescue Exception => e
      logger.aborting "Caught exception: #{e}"
      abort
    else
      logger.notice "Success! Starting instance"
      begin
        AWS_OPSWORKS.start_instance instanceid_options
      rescue Exception => e
        logger.aborting "Caught exception: #{e}"
        abort
      end
    end
  end
end

