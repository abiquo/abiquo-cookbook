rhsm_register node['fqdn'] do
  username node['rhn_register']['username']
  password node['rhn_register']['password']
  action :unregister
end
