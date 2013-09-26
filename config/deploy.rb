begin
  require 'rainbow'
  require 'aws-sdk'
  require 'railsless-deploy' 
rescue LoadError
  abort "No soup for you! Please run 'bundle install'"
end

# aws auth
AWS.config(YAML.load_file('config/aws.yml')['default'])
AWS_OPSWORKS = AWS::OpsWorks.new.client
AWS_S3 = AWS::S3.new

# load includes for cleanliness
Dir.glob('config/include/*.rb') do |file|
  load "#{file}"
end

# opts
default_run_options[:pty] = true
ssh_options[:forward_agent] = true

# start deploying
namespace :deploy do
  task :start do ; end
  task :stop do ; end
end

