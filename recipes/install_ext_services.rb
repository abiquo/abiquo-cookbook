# Cookbook Name:: abiquo
# Recipe:: install_ext_services
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

Chef::Recipe.send(:include, Abiquo::Commands)

case node['abiquo']['profile']
when 'monolithic', 'server', 'ext_services'
  recipes = %w(mariadb redis rabbitmq)
when 'remoteservices'
  recipes = %w(redis)
when 'monitoring'
  recipes = %w(mariadb)
else
  recipes = []
end

recipes.each do |recipe|
  include_recipe "abiquo::install_#{recipe}"
end
