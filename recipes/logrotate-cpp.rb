
#Copy Template for CPP logrotation

template '/etc/logrotate.d/cpp' do
  source 'logrotate-cpp.erb'

end

template '/etc/s3/s3_upload_servicelogs.sh' do
  source 'script-servicelogs-cpp.erb'
end
