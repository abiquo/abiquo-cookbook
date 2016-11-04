# Cookbook Name:: rhn_register
# Recipe:: register
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

rhsm_register node['fqdn'] do
  username node['rhn_register']['username']
  password node['rhn_register']['password']
  install_katello_agent false
  auto_attach true
  action :register
end
