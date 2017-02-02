# Cookbook Name:: abiquo
# Recipe:: upgrade
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

return unless ::File.executable?('/usr/bin/repoquery')

Chef::Recipe.send(:include, Abiquo::Packages)
Chef::Recipe.send(:include, Abiquo::Commands)

unless abiquo_update_available
  log 'No Abiquo updates found.'
  return
end

log 'Abiquo updates available.'

services = {
  'monolithic' => %w(abiquo-tomcat apache2 websockify),
  'remoteservices'    => %w(abiquo-tomcat),
  'server'            => %w(abiquo-tomcat apache2 websockify),
  'kvm'               => %w(abiquo-aim),
  'monitoring'        => %w(abiquo-delorean abiquo-emmett),
  'ui'                => %w(apache2),
  'v2v'               => %w(abiquo-tomcat),
  'websockify'        => %w(websockify)
}

services[node['abiquo']['profile']].each do |svc|
  service svc do
    action :stop
  end
end

include_recipe 'abiquo::repository'

abiquo_packages.each do |pkg|
  package pkg do
    action :upgrade
  end
end

services[node['abiquo']['profile']].each do |svc|
  service svc do
    action :start
  end
end

lqb_cmd = node['abiquo']['profile'] == 'monitoring' ? liquibase_cmd('update', node['abiquo']['monitoring']['db'], true) : liquibase_cmd('update', node['abiquo']['db'])
execute 'liquibase-update' do
  command lqb_cmd
  cwd '/usr/share/doc/abiquo-model/database'
  only_if { (node['abiquo']['profile'] == 'monolithic' || node['abiquo']['profile'] == 'server') && node['abiquo']['db']['upgrade'] }
  action :nothing
  subscribes :run, 'package[abiquo-server]', :immediately
  notifies :restart, 'service[abiquo-tomcat]' if node['abiquo']['profile'] == 'monolithic' || node['abiquo']['profile'] == 'server'
end

execute 'watchtower-liquibase-update' do
  only_if { node['abiquo']['profile'] == 'monitoring' }
  command lqb_cmd
  subscribes :run, 'package[abiquo-delorean]', :immediately
  notifies :restart, 'service[abiquo-delorean]' if node['abiquo']['profile'] == 'monitoring'
  action :nothing
end

include_recipe 'abiquo::default'
