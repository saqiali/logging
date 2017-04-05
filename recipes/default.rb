#
# Cookbook Name:: testing
# Recipe:: default
#
# Copyright 2017, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#


## rsyslog service that needs restart after the below config changes
service 'rsyslog' do
  supports :status => true, :restart => true, :reload => true
  action [:start, :enable]
end



#A cookbook_file resource block manages files by using files that exist within a cookbook’s /files directory. 
# 

cookbook_file '/tmp/commands.conf' do
  source 'commands.conf'
end

cookbook_file '/tmp/rsyslog.conf' do
  source 'rsyslog.conf'
end

## Appending lines to /etc/bashrc && only append if some string is not already there.
## Second one is appending in rsyslog directory
bash 'append_to_bashrc' do
  user 'root'
  code <<-EOH
  cat /tmp/commands.conf >> /etc/bashrc
  rm /tmp/commands.conf
  EOH
  not_if 'grep -q local6.debug /etc/bashrc'
end

bash 'append_to_rsyslog.d' do
  user 'root'
  code <<-EOH
  cat /tmp/rsyslog.conf >> /etc/rsyslog.d/bash.conf
  rm /tmp/rsyslog.conf
  EOH
  not_if 'grep -q local6 /etc/rsyslog.d/bash.conf'
  notifies :restart, 'service[rsyslog]'
end

#installing/upgrading aws cli version to latest

case node[platform]

when 'ubuntu'
  package 'awscli' do
    action :install
  end
  
when 'redhat', 'centos', 'fedora', 'amazon'
   package 'aws-cli' do
        action :install
      end
         
end

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

cron 'servicelogs' do
  hour '2'
  minute '0'
  command '/etc/s3/s3_upload_servicelogs.sh &>> /var/log/s3_backup/s3_backup.log'
end





