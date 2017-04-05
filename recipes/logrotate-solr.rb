# Template for solr log files  

template '/etc/logrotate.d/solr' do
  source 'logrotate-solr.erb'
end


## we define service script for nginx log files , and add cron job to crontab

template '/etc/s3/s3_upload_servicelogs.sh' do
  source 'script-servicelogs-solr.erb'
end

execute 'chmod a+x' do
  cwd '/etc/s3'
  command 'chmod a+x s3*.sh'
  action :run
end