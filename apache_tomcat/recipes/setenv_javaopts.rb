install_dir=node['tomcat']['install_dir']
tomcat_user=node['tomcat']['tomcat_user']

# check if JAVA_OPTS is empty:
if node['deploy'][node[:opsworks][:instance][:hostname].chop]['environment']['JAVA_OPTS']
  javaopts = node['deploy'][node[:opsworks][:instance][:hostname].chop]['environment']['JAVA_OPTS']
end rescue NoMethodError

# fill in setenv template:
template "#{install_dir}/bin/setenv.sh" do
  source "setenv.sh.erb"
  owner "#{tomcat_user}"
  mode "0755"
  variables({
    :JAVAOPTS => "#{javaopts}"
  })
end
