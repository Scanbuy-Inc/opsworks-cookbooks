cookbook_file "/opt/assigndomain.py" do
  source "assigndomain.py"
  mode 0500
end

execute "Update pip" do
  command "pip install -U pip"
  user "root"
end

execute "Install boto3" do
  command "pip install boto3"
  user "root"
end

params = "dev"+node[:opsworks][:instance][:hostname]+"."+node[:dnszone]+" "+node[:zoneid]
puts #{params}

execute "assigndomain" do
  command "/opt/assigndomain.py #{params}"
  user "root"
end
