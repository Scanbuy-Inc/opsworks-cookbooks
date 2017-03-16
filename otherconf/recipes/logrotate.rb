# Rotate user mails:
file '/etc/logrotate.d/mails' do
    content '/var/spool/mail/* {
        rotate 5
        dateext
        dateformat -%Y%m%d
        compress
        missingok
        notifempty
        size 2M
        copytruncate
        sharedscripts
}
'
    mode '0644'
    owner 'root'
    group 'root'
end

# Rotate war logs:
conf_dir="/opt/logrotate.d"
number=node[:opsworks][:instance][:hostname][-1,1]
webapp=node[:opsworks][:instance][:hostname].chop
country=node[:opsworks][:stack][:name][-2,2]

directory "#{conf_dir}" do
  owner "root"
  group "root"
  mode "0744"
  action :create
end

if webapp == "api2coupons" || webapp == "api2pos" || webapp == "settlement"
  contractornumber="1"
elsif webapp == "api2campaignmgr" || webapp == "campaignmgr" || webapp == "mycoupons"
  contractornumber="2"
end

if country == "us"
  urlext="com"
else
  urlext="#{country}"
end

puts "== Creating logrotate config and cronjob for #{webapp} =="
# Create logrotate conf:
apps=['api2coupons','api2pos','settlement','api2campaign','campaignmgr','mycoupons']
apps.each{ |eachapp|
  template "#{conf_dir}/#{eachapp}.conf" do
    source "prod.conf.erb"
    owner "root"
    group "root"
    mode "0744"
    action :create
    variables({
      :APPNAME => "#{eachapp}",
      :NUMBER => "#{number}",
      :CONTRACTORNUMBER => "#{contractornumber}",
      :URLEXT => "#{urlext}"
    })
}
end

# Create catalina.out conf:
file "#{conf_dir}/tomcat.conf" do
  content "/usr/share/tomcat7/logs/catalina.out {
        copytruncate
        dateext
        daily
        rotate 8
        compress
        missingok
        size 2M
}
"
  mode '0744'
  owner 'root'
  group 'root'
end

# Create cronjob:
template "/etc/crontab" do
  source "crontab.erb"
  owner "root"
  group "root"
  mode "0644"
  action :create
  variables({:APPNAME => "#{webapp}"})
end
