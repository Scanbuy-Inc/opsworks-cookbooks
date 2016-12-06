# binary:
cookbook_file '/usr/sbin/haproxy' do
	source 'haproxy'
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
	action :create
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

# dcoupon.eu SSL cert:
cookbook_file '/etc/pki/tls/private/dcoupon-eu-wild.pem' do
	source 'dcoupon-eu-wild.pem'
	mode '0600'
	owner 'root'
	group 'root'
	action :create_if_missing
end

execute "Add haproxy to chkconfig" do
  user "root"
  group "root"
  command "chkconfig --add haproxy"
  action :run
end

service "haproxy" do
  action [:enable,:start]
end
