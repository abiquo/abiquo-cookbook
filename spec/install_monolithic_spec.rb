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

describe 'abiquo::install_monolithic' do
    let(:chef_run) { ChefSpec::SoloRunner.new.converge(described_recipe) }

    before do
        stub_command('/usr/sbin/httpd -t').and_return(true)
    end

    it 'removes the MySQL packages' do
        expect(chef_run).to purge_package('mysql-libs').with(
            :ignore_failure => true
        )
    end

    %w{MariaDB-server MariaDB-client redis liquibase rabbitmq-server jdk}.each do |pkg|
        it "installs the #{pkg} system package" do
            expect(chef_run).to install_package(pkg)
        end
    end

    %w{mysql rabbitmq-server}.each do |svc|
        it "configures the #{svc} service" do
            expect(chef_run).to enable_service(svc)
            expect(chef_run).to start_service(svc)
        end
    end

    it 'installs the Apache recipes' do
        expect(chef_run).to include_recipe('apache2')
        expect(chef_run).to include_recipe('apache2::mod_proxy_ajp')
        expect(chef_run).to include_recipe('apache2::mod_ssl')
    end

    %w{abiquo-monolithic abiquo-sosreport-plugins}.each do |pkg|
        it "installs the #{pkg} abiquo package" do
            expect(chef_run).to install_package(pkg)
        end
    end

    it 'includes the certificate recipe' do
        expect(chef_run).to include_recipe('abiquo::certificate')
    end

    # The apache webapp and the iptables_rule calls can't be tested because they are not a LWRPs
    # but definitions and do not exist in the resource list

    it 'configures the firewall' do
        expect(chef_run).to permissive_selinux_state('SELinux Permissive')
        expect(chef_run).to include_recipe('iptables')
        expect(chef_run).to include_recipe('apache2::iptables')
    end

    %w{rpcbind redis}.each do |svc|
        it "configures the #{svc} service" do
            expect(chef_run).to enable_service(svc)
            expect(chef_run).to start_service(svc)
        end
    end
end
