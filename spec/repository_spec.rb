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

require 'spec_helper'

describe 'abiquo::repository' do
    let(:chef_run) { ChefSpec::SoloRunner.new }

    it 'cleans the yum cache' do
        chef_run.converge(described_recipe)
        resource = chef_run.execute('clean-yum-cache')
        expect(resource).to do_nothing
        expect(resource.command).to eq('yum clean all')
    end

    it 'deletes the yum cache directory' do
        chef_run.converge(described_recipe)
        resource = chef_run.directory('/var/cache/yum')
        expect(resource).to do_nothing
        expect(resource.ignore_failure).to eq(true)
        expect(resource.recursive).to eq(true)
    end

    it 'installs the epel-release package' do
        chef_run.converge(described_recipe)
        expect(chef_run).to install_package('epel-release')
    end

    it 'creates the base repository' do
        chef_run.converge(described_recipe)
        expect(chef_run).to create_yum_repository('abiquo-base').with(
            :description => 'Abiquo base repository',
            :baseurl => 'http://mirror.abiquo.com/abiquo/3.8/os/x86_64',
            :gpgcheck => true,
            :gpgkey => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-Abiquo ' \
                       'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-MariaDB ' \
                       'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-RabbitMQ ' \
                       'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6 ' \
                       'file:///etc/pki/rpm-gpg/RPM-GPG-RSA-KEY-Abiquo'
        )

        resource = chef_run.find_resource(:yum_repository, 'abiquo-base')
        expect(resource).to subscribe_to('package[abiquo-release-ee]').on(:create)
        expect(resource).to notify('directory[/var/cache/yum]').to(:delete).immediately
        expect(resource).to notify('execute[clean-yum-cache]').to(:run).immediately
    end

    it 'creates the updates repository' do
        chef_run.converge(described_recipe)
        expect(chef_run).to create_yum_repository('abiquo-updates').with(
            :description => 'Abiquo updates repository',
            :baseurl => 'http://mirror.abiquo.com/abiquo/3.8/updates/x86_64',
            :gpgcheck => true,
            :gpgkey => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-Abiquo ' \
                       'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-MariaDB ' \
                       'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-RabbitMQ ' \
                       'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6 ' \
                       'file:///etc/pki/rpm-gpg/RPM-GPG-RSA-KEY-Abiquo'
        )

        resource = chef_run.find_resource(:yum_repository, 'abiquo-updates')
        expect(resource).to subscribe_to('package[abiquo-release-ee]')
        expect(resource).to notify('directory[/var/cache/yum]').to(:delete).immediately
        expect(resource).to notify('execute[clean-yum-cache]').to(:run).immediately
    end

    it 'installs the abiquo-release-ee package' do
        chef_run.converge(described_recipe)
        expect(chef_run).to install_package('abiquo-release-ee').with(
            :options => '--nogpgcheck'
        )
    end

    it 'installs yum-utils package' do
        chef_run.converge(described_recipe)
        expect(chef_run).to install_package('yum-utils')
    end
end
