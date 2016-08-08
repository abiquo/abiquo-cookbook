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
    log "No Abiquo updates found."
    return
end

log "Abiquo updates available."

case node['abiquo']['profile']
when "kvm"
    services = %w{abiquo-aim}
when "monitoring"
    services = %w{abiquo-delorean abiquo-emmett}
else
    services = %w{abiquo-tomcat}
end

services.each  do |svc|
    service svc do
        action :stop
    end
end

include_recipe "abiquo::repository"

abiquo_packages.each do |pkg|
    package pkg do
        action :upgrade
    end
end

services.each  do |svc|
    service svc do
        action :start
    end
end

liquibasecmd = liquibase_cmd("update", node['abiquo']['db'])
execute "liquibase-update" do
    command liquibasecmd
    cwd '/usr/share/doc/abiquo-server/database'
    only_if { (node['abiquo']['profile'] == 'monolithic' || node['abiquo']['profile'] == 'server') && node['abiquo']['db']['upgrade'] }
    action :nothing
    subscribes :run, "package[abiquo-server]", :immediately
    notifies :restart, "service[abiquo-tomcat]" if node['abiquo']['profile'] == 'monolithic' || node['abiquo']['profile'] == 'server'
end

execute "watchtower-liquibase-update" do
  only_if { node['abiquo']['profile'] == 'monitoring' }
  command "/usr/bin/abiquo-watchtower-liquibase update"
  action :nothing
end

include_recipe "abiquo::setup_#{node['abiquo']['profile']}"
