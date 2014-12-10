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
end

directory "/var/cache/yum" do
    ignore_failure true
    recursive true
    action :delete
end

include_recipe "yum"

gpg_keys = gpg_key_files.join(" ")

yum_repository "abiquo-base" do
    description "Abiquo base repository"
    baseurl node['abiquo']['yum']['base-repo']
    gpgcheck true
    gpgkey gpg_keys
    action :create
    subscribes :create, "package[abiquo-release-ee]", :immediately
end

yum_repository "abiquo-updates" do
    description "Abiquo updates repository"
    baseurl node['abiquo']['yum']['updates-repo']
    gpgcheck true
    gpgkey gpg_keys
    action :create
    subscribes :create, "package[abiquo-release-ee]", :immediately
end

yum_repository "abiquo-nightly" do
    description "Abiquo nightly packages"
    baseurl node['abiquo']['yum']['nightly-repo']
    gpgcheck false
    gpgkey gpg_keys
    action :create
    not_if { node['abiquo']['yum']['nightly-repo'].nil? }
end

package "yum-utils" do
    action :install
end

# This package contains the gpgkey file, so the signature cannot
# be validated when installing it.
package "abiquo-release-ee" do
    options "--nogpgcheck"
    action :install
end

# Once the abiquo-release package is installed, detect the platform again
ohai "reload" do
    action :reload
end

# In Abiquo the family is not set. Force it to the right value
node.set['platform_family'] = 'rhel'
