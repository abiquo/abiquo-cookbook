# Cookbook Name:: abiquo
# Recipe:: install_v2v
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

%w{redis jdk}.each do |pkg|
    package pkg do
        action :install
    end
end

include_recipe "abiquo::install_jce"

%w{v2v sosreport-plugins}.each do |pkg|
    package "abiquo-#{pkg}" do
        action :install
    end
end

include_recipe "iptables"
iptables_rule "firewall-policy-drop"
iptables_rule "firewall-abiquo"

%w{rpcbind redis}.each do |svc|
  service svc do
      action [:enable, :start]
  end
end
