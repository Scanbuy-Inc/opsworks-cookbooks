install_dir=node['tomcat']['install_dir']

template "/etc/profile.d/alias.sh" do
  source "alias.erb"
  owner "root"
  group 'root'
  mode "0644"
  action :create
  variables({:INSTALL_DIR => "#{install_dir}"})
end
