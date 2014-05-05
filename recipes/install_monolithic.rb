# Cookbook Name:: abiquo
# Recipe:: install_monolithic
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

package "mysql-libs" do
    ignore_failure true
    action :purge
end

%w{MariaDB-server MariaDB-client rabbitmq-server}.each do |pkg|
    package pkg do
        action :install
    end
end

%w{mysql rabbitmq-server}.each do |svc|
    service svc do
        action [:enable, :start]
    end
end

include_recipe "java"
include_recipe "redisio::install"
include_recipe "redisio::enable"

apache_module "proxy"
apache_module "proxy_ajp"

web_app "abiquo" do
    template "abiquo.conf.erb"
end

%w{monolithic sosreport-plugins}.each do |pkg|
    package "abiquo-#{pkg}" do
        action :install
    end
end

selinux_state "SELinux Permissive" do
    action :permissive
end

include_recipe "iptables"
iptables_rule "firewall-http"
iptables_rule "firewall-tomcat"
