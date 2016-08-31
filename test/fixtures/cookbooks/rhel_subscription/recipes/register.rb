rhsm_register node['hostname'] do
  username node['rhel_subscription']['username']
  password node['rhel_subscription']['password']
  auto_attach true
  install_katello_agent false
end