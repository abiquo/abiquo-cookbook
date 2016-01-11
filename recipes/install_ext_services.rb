# Cookbook Name:: abiquo
# Recipe:: certificate
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
