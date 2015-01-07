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
require_relative 'support/matchers'

describe 'abiquo::repository' do
    let(:chef_run) { ChefSpec::SoloRunner.new }

    it 'cleans the yum cache' do
        chef_run.converge(described_recipe)
        expect(chef_run).to run_execute('clean-yum-cache').with(
            :command => 'yum clean all'
        )
    end

    it 'deletes the yum cache directory' do
        chef_run.converge(described_recipe)
        expect(chef_run).to delete_directory('/var/cache/yum').with(
            :ignore_failure => true,
            :recursive => true
        )
    end

    it 'creates the base repository' do
        chef_run.converge(described_recipe)
        expect(chef_run).to create_yum_repository('abiquo-base').with(
            :description => 'Abiquo base repository',
            :baseurl => 'http://mirror.abiquo.com/abiquo/3.2/os/x86_64',
            :gpgcheck => true,
            :gpgkey => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-Abiquo ' \
                       'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-MariaDB ' \
                       'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-RabbitMQ'
        )

        resource = chef_run.find_resource(:yum_repository, 'abiquo-base')
        expect(resource).to subscribe_to('package[abiquo-release-ee]').on(:create)
    end

    it 'creates the updates repository' do
        chef_run.converge(described_recipe)
        expect(chef_run).to create_yum_repository('abiquo-updates').with(
            :description => 'Abiquo updates repository',
            :baseurl => 'http://mirror.abiquo.com/abiquo/3.2/updates/x86_64',
            :gpgcheck => true,
            :gpgkey => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-Abiquo ' \
                       'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-MariaDB ' \
                       'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-RabbitMQ'
        )

        resource = chef_run.find_resource(:yum_repository, 'abiquo-updates')
        expect(resource).to subscribe_to('package[abiquo-release-ee]')
    end

    it 'creates does not create the nightly packages repository by default' do
        chef_run.converge(described_recipe)
        expect(chef_run).to_not create_yum_repository('abiquo-nightly')
    end

    it 'creates the nightly packages repository' do
        chef_run.node.set['abiquo']['yum']['nightly-repo'] = 'http://localhost/abiquo/packages/nightly'
        chef_run.converge(described_recipe)
        expect(chef_run).to create_yum_repository('abiquo-nightly').with(
            :description => 'Abiquo nightly packages',
            :baseurl => 'http://localhost/abiquo/packages/nightly',
            :gpgcheck => false,
            :gpgkey => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-Abiquo ' \
                       'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-MariaDB ' \
                       'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-RabbitMQ'
        )
    end

    it 'installs the yum-utils package' do
        chef_run.converge(described_recipe)
        expect(chef_run).to install_package('yum-utils')
    end

    it 'installs the abiquo-release-ee package' do
        chef_run.converge(described_recipe)
        expect(chef_run).to install_package('abiquo-release-ee').with(
            :options => '--nogpgcheck'
        )
    end

    it 'reloads ohai' do
        chef_run.converge(described_recipe)
        expect(chef_run).to reload_ohai('reload')
    end
end
