rhsm_register node['fqdn'] do
  username node['rhn_register']['username']
  password node['rhn_register']['password']
  install_katello_agent false
  auto_attach true
  action :register
end
