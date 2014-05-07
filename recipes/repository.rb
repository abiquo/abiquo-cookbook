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

# Cleanup the repos if the Abiquo ones are not present
unless ::File.exists?("/etc/yum.repos.d/abiquo-base")
    directory "/etc/yum.repos.d" do
        recursive true
        action :delete
        ignore_failure true
    end

    directory "/etc/yum.repos.d" do
        owner "root"
        group "root"
        action :create
    end
end

yum_repository "centos-base" do
    description "CentOS 6 - Base"
    baseurl "http://mirror.abiquo.com/mirror.centos.org/centos-6/6/os/x86_64/"
    gpgkey "file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6"
    action :create
end

yum_repository "centos-updates" do
    description "CentOS 6 - Updates"
    baseurl "http://mirror.abiquo.com/mirror.centos.org/centos-6/6/updates/x86_64/"
    gpgkey "file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6"
    action :create
end

yum_repository "abiquo-base" do
    description "Abiquo 3.0 - Base"
    baseurl "http://mirror.abiquo.com/abiquo/3.0/os/x86_64"
    gpgcheck false
    gpgkey "file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6"
    action :create
end

package "abiquo-release-ee" do
    action :install
end

yum_repository "abiquo-base" do
    description "Abiquo 3.0 - Base"
    baseurl "http://mirror.abiquo.com/abiquo/3.0/os/x86_64"
    gpgcheck true
    gpgkey "file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6"
    action :create
end

yum_repository "abiquo-nightly" do
    description "Abiquo nightly packages"
    baseurl node['abiquo']['nightly-repo']
    gpgcheck false
    gpgkey "file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6"
    action :create
    not_if { node['abiquo']['nightly-repo'].nil? }
end

# Once the abiquo-release package is installed, detect the platform again
ohai "reload" do
    action :reload
end

# In Abiquo the family is not set. Force it to the right value
node.set['platform_family'] = 'rhel'
