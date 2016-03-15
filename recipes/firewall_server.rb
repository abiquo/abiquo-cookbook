# Cookbook Name:: abiquo
# Recipe:: install_monitoring
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

# Apache ports
node['apache']['listen_ports'].each do |p| 
  firewall_rule "apache-#{p}" do
    port     p.to_i
    command  :allow
  end
end

if node['abiquo']['install_ext_services']
  # RabbitMQ
  firewall_rule 'rabbitmq' do
    port     5672
    command  :allow
  end

  # MySQL
  firewall_rule 'mariadb' do
    port     3306
    command  :allow
  end
end 

include_recipe "abiquo::firewall_tomcat"
