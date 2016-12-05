# binary:
cookbook_file '/usr/sbin/haproxy' do
	source 'haproxy.bin'
	mode '0755'
	owner 'root'
	group 'root'
	action :create_if_missing
end

# config:
directory '/etc/haproxy' do
	mode '0755'
	owner 'root'
	group 'root'
	action :create_if_missing
end

cookbook_file '/etc/haproxy/haproxy.cfg' do
	source 'haproxy.cfg'
	mode '0644'
	owner 'root'
	group 'root'
	action :create_if_missing
end

# init script:
cookbook_file '/etc/init.d/haproxy' do
	source 'haproxy.init'
	mode '0755'
	owner 'root'
	group 'root'
	action :create_if_missing
end

execute "Add tomcat7 to chkconfig" do
  user "root"
  group "root"
  command "chkconfig --add haproxy"
  action :run
end

service "haproxy" do
  action [:enable,:start]
end
