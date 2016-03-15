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

# Enable the KairosDB port
firewall_rule 'kairosdb' do
  port     node['abiquo']['monitoring']['kairosdb']['port']
  command  :allow
end

# Enable the Cassandra clients port
firewall_rule 'cassandra-rpc' do
  port     node['cassandra']['config']['rpc_port']
  command  :allow
end

# Enable the Cassandra inter-node communication port
firewall_rule 'cassandra-storage' do
  port     node['cassandra']['config']['storage_port']
  command  :allow
end

# Enable Emmett port
firewall_rule 'emmett' do
  port     node['abiquo']['monitoring']['emmett']['port']
  command  :allow
end
