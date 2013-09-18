namespace :cook do
  task :default do
    if ! ENV['ENV']
      logger.aborting "You need to set ENV"
      abort
    end

    set :env, ENV['ENV']
    set :base_path, File.expand_path('.cook', File.dirname(__FILE__))
    set :install_path, "#{base_path}/cookbooks-#{env}"
    set :cookbook_tarball, "cookbooks-#{env}.tgz"
    set :cookbook_upload, "#{base_path}/#{cookbook_tarball}"
    set :s3_namespace, 'mapzen.opsworks'

    # build
    logger.notice 'Running berks and archiving'
    run_locally "berks update && berks install --path #{install_path}"

    FileUtils.mkdir_p("#{base_path}")
    run_locally "tar czf #{cookbook_upload} -C #{install_path} ."

    # upload
    logger.notice 'Uploading to S3'

    begin
      obj = AWS_S3.buckets["#{s3_namespace}-#{env}"].objects["#{cookbook_tarball}"]
      obj.write(:file => "#{cookbook_upload}")
    rescue Exception => e
      logger.achtung "Caught exception while uploading to S3 bucket #{s3_namespace}-#{env}: #{e}"
    else
      logger.notice "Completed successful upload of #{cookbook_tarball} to #{s3_namespace}.opsworks-#{env}!"
    end

    # cleanup
    logger.notice 'Cleaning up'
    FileUtils.rm_rf("#{base_path}")
    logger.notice 'Done!'
  end
end

