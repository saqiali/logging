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

package 'aws-cli' do
  action :install
end






