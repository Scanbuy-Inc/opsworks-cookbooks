install_dir=node['tomcat']['install_dir']
conf_dir="#{install_dir}/conf"
domain=node['dnszone']

template "#{conf_dir}/server.xml" do
  source "server.xml"
  owner "root"
  group "root"
  mode "0600"
  action :create
end
