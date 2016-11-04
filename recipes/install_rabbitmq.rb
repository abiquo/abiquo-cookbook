# Cookbook Name:: abiquo
# Recipe:: install_rabbitmq
#
# Copyright 2014, Abiquo
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

include_recipe 'rabbitmq'

rabbitmq_user node['abiquo']['rabbitmq']['username'] do
  password node['abiquo']['rabbitmq']['password']
  action :add
end

rabbitmq_user node['abiquo']['rabbitmq']['username'] do
  tag node['abiquo']['rabbitmq']['tags']
  action :set_tags
end

rabbitmq_user node['abiquo']['rabbitmq']['username'] do
  vhost node['abiquo']['rabbitmq']['vhost']
  permissions '.* .* .*'
  action :set_permissions
  notifies :restart, 'service[abiquo-tomcat]' unless node['abiquo']['profile'] == 'ext_services'
end
