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

execute "update-apt-cache" do
    command "apt-get clean && apt-get update"
    action :run
end

apt_repository 'abiquo-nightly' do
  uri node['abiquo']['apt']['nightly-repo']
  distribution node['lsb']['codename']
  components ['main']
  action :add
  not_if { node['abiquo']['yum']['nightly-repo'].nil? }
end

package 'curl'

execute "install-abiquo-repository" do
    command "curl -s https://packagecloud.io/install/repositories/abiquo/#{node['abiquo']['repo']}/script.deb.sh | sudo bash"
    action :run
    creates "/etc/apt/sources.list.d/abiquo_#{node['abiquo']['repo']}.list"
    notifies :run, 'execute[update-apt-cache]', :immediately
end
