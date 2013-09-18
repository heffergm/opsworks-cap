namespace :opsworks do
  desc 'List stacks'
  task :list_stacks do

    logger.notice 'Available stacks: '
    begin
      response = AWS_OPSWORKS.describe_stacks
    rescue Exception => e
      logger.achtung "Exception raised: #{e}"
    else
      response[:stacks].each { |stack| logger.info stack.values_at(:name, :stack_id).join(', ') } 
    end
  end

  desc 'List stacks'
  task :list_layers do
    desc 'List layers for a given stack'

    set(:mystack, Capistrano::CLI.ui.ask("What stack do you want layer details for: "))
    begin
      response = AWS_OPSWORKS.describe_layers(options = {:stack_id => "#{mystack}"})
      response[:layers].each { |layer| logger.info layer.values_at(:name, :layer_id).join(', ') } 
    rescue Exception => e
      logger.achtung "Exception raised: #{e}"
    end
  end

  desc 'Run deployment command'
  task :cmd do
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
      logger.achtung "Caught exception: #{e}"
    else
      logger.notice "Success!"
    end
  end
end

