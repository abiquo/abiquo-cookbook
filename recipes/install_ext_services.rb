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

package "mysql-libs" do
    ignore_failure true
    action :purge
end

case node['abiquo']['profile']
when "monolithic", "server"
    packages = %w{MariaDB-server MariaDB-client redis rabbitmq-server}
    services = %w{mysql redis rabbitmq-server}
when "remoteservices"
    packages = %w{redis}
    services = %w{redis}
when "monitoring"
    packages = %w{MariaDB-server MariaDB-client}
    services = %w{mysql}
end

packages.each do |pkg|
    package pkg do
        action :install
    end
end

services.each do |svc|
    service svc do
        action [:enable, :start]
    end
end

execute "create-abiquo-rabbit-user" do
    command "rabbitmqctl add_user #{node['abiquo']['properties']['abiquo.rabbitmq.username']} #{node['abiquo']['properties']['abiquo.rabbitmq.username']}"
    action :nothing
    subscribes :run, "service[rabbitmq-server]"
    not_if "rabbitmqctl list_users | egrep -q '^#{node['abiquo']['properties']['abiquo.rabbitmq.username']}.*'"
end

execute "set-abiquo-rabbit-user-administrator" do
    command "rabbitmqctl set_user_tags #{node['abiquo']['properties']['abiquo.rabbitmq.username']} administrator"
    action :nothing
    subscribes :run, "execute[create-abiquo-rabbit-user]"
end

execute "set-abiquo-rabbit-user-permissions" do
    command "rabbitmqctl set_permissions -p / #{node['abiquo']['properties']['abiquo.rabbitmq.username']} '.*' '.*' '.*'"
    action :nothing
    subscribes :run, "execute[create-abiquo-rabbit-user]"
end
