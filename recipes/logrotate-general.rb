#Copy Template for commands logrotation
template '/etc/logrotate.d/commands' do
  source 'logrotate-commands.erb'
  owner 'root'
  group 'root'
  mode '0644'
end


#Copy Template for syslog logrotation

template '/etc/logrotate.d/syslog' do
  source 'logrotate-syslog.erb'

end

#Copy Template for logrotate.conf file 

template '/etc/logrotate.conf' do
  source 'logrotate.conf.erb'

end

#Copy Template for /etc/anacrontab file to set cron job timings

template '/etc/anacrontab' do
  source 'anacrontab.erb'

end

#Create directory to save s3 scripts , copy template of s3 scripts to this 
#directory and give a+x permission to run script

directory '/etc/s3' do
  action :create
end

directory '/var/log/s3_backup' do
  action :create
end


template '/etc/s3/s3_upload_systemlogs.sh' do
  source 'script-systemlogs.erb'
end

execute 'chmod a+x' do
  cwd '/etc/s3'
  command 'chmod a+x s3*.sh'
  action :run
end

cron 'systemlogs' do
  hour '2'
  minute '0'
  command '/etc/s3/s3_upload_systemlogs.sh &>> /var/log/s3_backup/s3_backup.log'
end


