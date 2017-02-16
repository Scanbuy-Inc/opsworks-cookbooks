direct_download_version=node['tomcat']['direct_download_version']
direct_download_url= "http://archive.apache.org/dist/tomcat/tomcat-7/v"+"#{direct_download_version}"+"/bin/apache-tomcat-#{direct_download_version}.tar.gz";

install_dir=node['tomcat']['install_dir']
webapps_base_dir="#{install_dir}/webapps"
conf_dir="#{install_dir}/conf"
lib_dir="#{install_dir}/lib"

tomcat_user=node['tomcat']['tomcat_user']
tomcat_group=node['tomcat']['tomcat_group']

script "Download Apache Tomcat #{direct_download_version}" do
  interpreter "bash"
  user "#{tomcat_user}"
  cwd "/opt"
  code <<-EOH
  wget "#{direct_download_url}" -O "/opt/apache-tomcat-#{direct_download_version}.tar.gz";
  mkdir -p "#{install_dir}"
  EOH
end

execute "Unzip Apache Tomcat #{direct_download_version}" do
  user "#{tomcat_user}"
  group "#{tomcat_group}"
  cwd "#{install_dir}"
  command "tar zxf /opt/apache-tomcat-#{direct_download_version}.tar.gz -C #{install_dir} --strip-components=1"
  action :run
end

template "#{install_dir}/bin/setenv.sh" do
  source "setenv.sh.erb"
  owner "#{tomcat_user}"
  mode "0755"
end

template "/etc/rc.d/init.d/tomcat7" do
  source "tomcat7.erb"
  owner "#{tomcat_user}"
  mode "0755"
end

# Add runlevel3 startup:
link '/etc/rc3.d/S80tomcat7' do
  to '/etc/rc.d/init.d/tomcat7'
  group "root"
  owner "root"
  link_type :symbolic
end

execute "Add tomcat7 to chkconfig" do
  user "root"
  group "root"
  command "chkconfig --add tomcat7"
  action :run
end

ruby_block 'remove all default webapp' do
  block do
    Dir.foreach(webapps_base_dir) do |f|
      fn = File.join(webapps_base_dir, f)
      FileUtils.rm_rf(fn) if f != '.' && f != '..'
    end
  end
end

# Disable autoDeploy:
if File.exist?("#{conf_dir}/server.xml")
  puts "Disable autoDeploy in server.xml"
  newcontent=File.read("#{conf_dir}/server.xml").gsub(/autoDeploy=\"true\"/, "autoDeploy=\"false\"")
  File.open("#{conf_dir}/server.xml.new", "w"){|newconf| newconf.puts newcontent }
  File.delete("#{conf_dir}/server.xml")
  File.rename("#{conf_dir}/server.xml.new","#{conf_dir}/server.xml")
else
  puts "  #{conf_dir}/server.xml does not exist, skip disabling autoDeploy block."
end

# MSM setup (context.xml):
template "#{conf_dir}/context.xml" do
  source "context.xml.erb"
  owner "root"
  group "root"
  mode "0600"
  action :create
end

# MSM setup (jars):
cookbook_file "/opt/msm_jarlist" do
  source "msm_jarlist"
  mode 0600
end

script "Download MSM JARs" do
  interpreter "bash"
  user "root"
  group "root"
  cwd "#{lib_dir}"
  code <<-EOH
  wget -i /opt/msm_jarlist
  EOH
end

cookbook_file "#{lib_dir}/objenesis-2.4.jar" do
  source "objenesis-2.4.jar"
  user "root"
  group "root"
  mode 0644
end

cookbook_file "#{lib_dir}/AmazonElastiCacheClusterClient-1.1.1.jar" do
  source "AmazonElastiCacheClusterClient-1.1.1.jar"
  user "root"
  group "root"
  mode 0644
end
