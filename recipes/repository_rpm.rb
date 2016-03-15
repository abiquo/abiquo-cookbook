# Cookbook Name:: abiquo
# Recipe:: repository
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

execute "clean-yum-cache" do
    command "yum clean all"
    action :nothing
end

%w{epel-release yum-utils}.each do |pkg|
    package pkg do
        action :install
    end
end

yum_repository "abiquo-nightly" do
    description "Abiquo nightly packages"
    baseurl node['abiquo']['yum']['nightly-repo']
    gpgcheck false
    action :create
    notifies :run, 'execute[clean-yum-cache]', :immediately
    not_if { node['abiquo']['yum']['nightly-repo'].nil? }
end

execute "install-abiquo-repository" do
    command "curl -s https://packagecloud.io/install/repositories/abiquo/#{node['abiquo']['repo']}/script.rpm.sh | sudo bash"
    action :run
    creates "/etc/yum.repos.d/abiquo_#{node['abiquo']['repo']}.repo"
    notifies :run, 'execute[clean-yum-cache]', :immediately
end
