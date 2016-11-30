cookbook_file "/etc/profile.d/alias.sh" do
  source "alias.sh"
  mode '0644'
  group 'root'
  owner 'root'
  action :create
end
