# Cookbook Name:: abiquo
# Recipe:: install_kairosdb
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

package 'kairosdb' do
  action :install
  # We want the service to be stopped immediately after the rpm package starts it, if we are going
  # to replace its config file by a systemd unit. Otherwise we won't be able to properly manage it.
  notifies :stop, 'service[kairosdb]', :immediately if node['platform_version'].to_i == 7
  notifies :disable, 'service[kairosdb]', :immediately if node['platform_version'].to_i == 7
end

service 'kairosdb' do
  action :enable
end
