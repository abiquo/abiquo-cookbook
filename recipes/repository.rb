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

# Remove all existing Abiquo repositories
Dir.glob("/etc/yum.repos.d/*abiquo*", File::FNM_CASEFOLD).each do |repo|
    file repo do
        action :delete
    end
end

yum_repository "abiquo-base" do
    description "Abiquo base repository"
    baseurl node['abiquo']['yum']['repository']
    gpgcheck false
    gpgkey "file:///etc/pki/rpm-gpg/RPM-GPG-KEY-Abiquo"
    action :create
end

package "abiquo-release-ee" do
    action :install
end

yum_repository "abiquo-base" do
    description "Abiquo base repository"
    baseurl node['abiquo']['yum']['repository']
    gpgcheck true
    gpgkey "file:///etc/pki/rpm-gpg/RPM-GPG-KEY-Abiquo"
    action :create
end

yum_repository "abiquo-nightly" do
    description "Abiquo nightly packages"
    baseurl node['abiquo']['nightly-repo']
    gpgcheck false
    gpgkey "file:///etc/pki/rpm-gpg/RPM-GPG-KEY-Abiquo"
    action :create
    not_if { node['abiquo']['nightly-repo'].nil? }
end

# Once the abiquo-release package is installed, detect the platform again
ohai "reload" do
    action :reload
end

# In Abiquo the family is not set. Force it to the right value
node.set['platform_family'] = 'rhel'
