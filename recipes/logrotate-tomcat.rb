# Template for nginx log files in /var/log/nginx 

template '/etc/logrotate.d/tomcat-catalina' do
  source 'logrotate-tomcat-catalina.erb'
end

template '/etc/logrotate.d/tomcat8' do
  source 'logrotate-tomcat.erb'
end
## we define service script for nginx log files , and add cron job to crontab

template '/etc/s3/s3_upload_servicelogs.sh' do
  source 'script-servicelogs-tomcat.erb'
end

execute 'chmod a+x' do
  cwd '/etc/s3'
  command 'chmod a+x s3*.sh'
  action :run
end
