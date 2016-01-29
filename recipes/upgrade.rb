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

Chef::Recipe.send(:include, Abiquo::Packages)

return if node['abiquo']['profile'].eql? "monitoring"

unless abiquo_update_available
  log "No Abiquo updates found."
  return
end

log "Abiquo updates available."

svc = node['abiquo']['profile'] == 'kvm' ? 'abiquo-aim' : 'abiquo-tomcat'
service svc do
    action :stop
end

include_recipe "abiquo::repository"

abiquo_packages.each do |pkg|
  package pkg do
    action :upgrade
    notifies :start, "service[#{svc}]"
  end
end

liquibase_cmd = "abiquo-liquibase -h #{node['abiquo']['db']['host']} "
liquibase_cmd += "-P #{node['abiquo']['db']['port']} "
liquibase_cmd += "-u #{node['abiquo']['db']['user']} "
liquibase_cmd += "-p #{node['abiquo']['db']['password']} " unless node['abiquo']['db']['password'].nil?
liquibase_cmd += "update"

execute "liquibase-update" do
    command liquibase_cmd
    cwd '/usr/share/doc/abiquo-server/database'
    only_if { (node['abiquo']['profile'] == 'monolithic' || node['abiquo']['profile'] == 'server') && node['abiquo']['db']['upgrade'] }
    action :nothing
    subscribes :run, "package[abiquo-server]", :immediately
    notifies :restart, "service[abiquo-tomcat]"
end

include_recipe "abiquo::setup_#{node['abiquo']['profile']}"
