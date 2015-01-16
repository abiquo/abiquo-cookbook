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

Chef::Recipe.send(:include, Abiquo::Platform)

services = case node['abiquo']['profile']
    # Order is important. The abiquo-tomcat will be stopped first and started at the end
    when 'monolithic' then ['abiquo-tomcat', 'redis', 'mysql', 'rabbitmq-server']
    when 'remoteservices' then ['abiquo-tomcat', 'redis']
    when 'kvm' then ['abiquo-aim']
end

services.each do |svc|
    service svc do
        action :stop
    end
end

include_recipe "abiquo::repository"

# Wildcards can't be used with the regular resource package, so just run the command
execute "yum-upgrade-abiquo" do
    command 'yum -y upgrade abiquo-*'
end

services.reverse.each do |svc|
    service svc do
        action :start
    end
end
