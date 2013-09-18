namespace :opsworks do
  task :list_stacks do
    desc 'List stacks'

    logger.notice 'Available stacks: '
    begin
      stacks = AWS_OPSWORKS.describe_stacks
    rescue
      logger.achtung "Exception raised: #{e}"
    else
      stacks.each { |h,k| logger.info k[:name] + ', ' + k[:stack_id] }
    end
  end

  task :list_layers do
    desc 'List layers for a given stack'

    set(:mystack, Capistrano::CLI.ui.ask("What stack do you want layer details for: "))
    begin
      layers = AWS_OPSWORKS.describe_layers(options = {:stack_id => "#{mystack}"})
      layers.each { |h,k| logger.info k[:name] + ', ' + k[:layer_id] } # not quite
    rescue Exception => e
      logger.achtung "Exception raised: #{e}"
    end
  end

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

