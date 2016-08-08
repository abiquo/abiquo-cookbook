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
require_relative 'support/packages'

describe 'abiquo::upgrade' do
    let(:chef_run) do
        ChefSpec::SoloRunner.new(internal_locale: 'en_US.UTF-8') do |node|
            node.set['abiquo']['certificate']['common_name'] = 'test.local'
        end
    end

    before do
        stub_command('/usr/sbin/httpd -t').and_return(true)
        stub_command("service abiquo-tomcat stop").and_return(true)
        stub_command("/usr/bin/mysql -h localhost -P 3306 -u root kinton -e 'SELECT 1'").and_return(false)
        allow(::File).to receive(:executable?).with('/usr/bin/repoquery').and_return(true)
        stub_package_commands(['abiquo-api', 'abiquo-server'])
    end

    it 'does nothing if repoquery is not installed' do
        allow(::File).to receive(:executable?).with('/usr/bin/repoquery').and_return(false)
        chef_run.converge('apache2::default', described_recipe)
        expect(chef_run.find_resource(:service, 'abiquo-tomcat')).to be_nil
        expect(chef_run.find_resource(:service, 'abiquo-aim')).to be_nil
        expect(chef_run.find_resource(:package, 'abiquo-api')).to be_nil
    end

    it 'logs a message if there are upgrades' do
        chef_run.converge('apache2::default', 'abiquo::install_server', described_recipe)
        expect(chef_run).to write_log("Abiquo updates available.")
    end

    it 'logs a message if there are no upgrades' do
        stub_available_packages(['abiquo-api', 'abiquo-server'], '-0:3.6.1-85.el6.noarch')
        chef_run.converge('apache2::default', described_recipe)
        expect(chef_run).to write_log("No Abiquo updates found.")
    end

    it 'does nothing if no updates available' do
        stub_available_packages(['abiquo-api', 'abiquo-server'], '-0:3.6.1-85.el6.noarch')
        chef_run.converge('apache2::default', described_recipe)
        expect(chef_run.find_resource(:service, 'abiquo-tomcat')).to be_nil
        expect(chef_run.find_resource(:service, 'abiquo-aim')).to be_nil
        expect(chef_run.find_resource(:package, 'abiquo-api')).to be_nil
    end

    it 'performs upgrade if there are new rpms' do
        chef_run.converge('apache2::default', described_recipe, 'abiquo::service', 'abiquo::install_server')
        expect(chef_run.find_resource(:service, 'abiquo-tomcat')).to_not be_nil
        expect(chef_run.find_resource(:service, 'abiquo-aim')).to be_nil
        expect(chef_run.find_resource(:package, 'abiquo-api')).to_not be_nil
    end

    %w{monolithic server}.each do |profile|
        it "stops the #{profile} services" do
            chef_run.node.set['abiquo']['profile'] = profile
            chef_run.converge('apache2::default', described_recipe, 'abiquo::service', 'abiquo::install_server')
            expect(chef_run).to stop_service('abiquo-tomcat')
            expect(chef_run).to_not stop_service('abiquo-aim')
            expect(chef_run).to_not stop_service('abiquo-delorean')
            expect(chef_run).to_not stop_service('abiquo-emmett')
        end
    end

    %w{remoteservices v2v}.each do |profile|
        it "stops the #{profile} services" do
            chef_run.node.set['abiquo']['profile'] = profile
            chef_run.converge('apache2::default', described_recipe, 'abiquo::service')
            expect(chef_run).to stop_service('abiquo-tomcat')
            expect(chef_run).to_not stop_service('abiquo-aim')
            expect(chef_run).to_not stop_service('abiquo-delorean')
            expect(chef_run).to_not stop_service('abiquo-emmett')
        end
    end

    it 'stops the kvm services' do
        chef_run.node.set['abiquo']['profile'] = 'kvm'
        chef_run.converge('apache2::default', described_recipe, 'abiquo::service')
        expect(chef_run).to_not stop_service('abiquo-tomcat')
        expect(chef_run).to_not stop_service('abiquo-delorean')
        expect(chef_run).to_not stop_service('abiquo-emmett')
        expect(chef_run).to stop_service('abiquo-aim')
    end

    it 'stops the monitoring services' do
        chef_run.node.set['abiquo']['profile'] = 'monitoring'
        chef_run.converge('apache2::default', described_recipe, 'abiquo::service')
        expect(chef_run).to_not stop_service('abiquo-tomcat')
        expect(chef_run).to_not stop_service('abiquo-aim')
        expect(chef_run).to stop_service('abiquo-delorean')
        expect(chef_run).to stop_service('abiquo-emmett')
    end

    it 'includes the repository recipe' do
        chef_run.converge('apache2::default', 'abiquo::install_server', described_recipe)
        expect(chef_run).to include_recipe('abiquo::repository')
    end

    it 'upgrades the abiquo packages on monolithic' do
        chef_run.converge('apache2::default', 'abiquo::install_server', described_recipe)
        %w{abiquo-api abiquo-server}.each do |pkg|
            expect(chef_run).to upgrade_package(pkg)
        end
    end

    it 'upgrades the abiquo packages on server' do
        chef_run.node.set['abiquo']['profile'] = 'server'
        chef_run.converge('apache2::default', 'abiquo::install_server', described_recipe)
        %w{abiquo-api abiquo-server}.each do |pkg|
            expect(chef_run).to upgrade_package(pkg)
        end
    end

    it 'upgrades the abiquo packages on remoteservices' do
        stub_package_commands(['abiquo-virtualfactory', 'abiquo-remote-services'])
        chef_run.node.set['abiquo']['profile'] = 'remoteservices'
        chef_run.converge('apache2::default', described_recipe)
        %w{abiquo-virtualfactory abiquo-remote-services}.each do |pkg|
            expect(chef_run).to upgrade_package(pkg)
        end
    end

    it 'upgrades the abiquo packages on kvm' do
        stub_package_commands(['abiquo-aim', 'abiquo-cloud-node'])
        chef_run.node.set['abiquo']['profile'] = 'kvm'
        chef_run.converge('apache2::default', described_recipe, 'abiquo::service')
        %w{abiquo-aim abiquo-cloud-node}.each do |pkg|
            expect(chef_run).to upgrade_package(pkg)
        end
    end

    it 'upgrades the abiquo packages on monitoring' do
        stub_package_commands(['abiquo-delorean', 'abiquo-emmett'])
        chef_run.node.set['abiquo']['profile'] = 'monitoring'
        chef_run.converge('apache2::default', described_recipe, 'abiquo::service')
        %w{abiquo-delorean abiquo-emmett}.each do |pkg|
            expect(chef_run).to upgrade_package(pkg)
        end
    end

    it 'does not run liquibase if not configured' do
        chef_run.node.set['abiquo']['db']['upgrade'] = false
        chef_run.node.set['abiquo']['profile'] = 'monolithic'
        chef_run.converge('apache2::default', described_recipe, 'abiquo::install_server', 'abiquo::service')
        expect(chef_run).to_not run_execute('liquibase-update')
    end

    %w{kvm remoteservices monitoring v2v}.each do |profile|
        it "does not run liquibase when #{profile}" do
            chef_run.node.set['abiquo']['db']['upgrade'] = true
            chef_run.node.set['abiquo']['profile'] = profile
            chef_run.converge('apache2::default', described_recipe, 'abiquo::service')
            expect(chef_run).to_not run_execute('liquibase-update')
        end
    end

    it 'runs the liquibase update when monolithic' do
        chef_run.converge('apache2::default', 'abiquo::install_server', described_recipe)
        resource = chef_run.find_resource(:execute, 'liquibase-update')
        expect(resource).to subscribe_to("package[abiquo-server]").on(:run).immediately
        expect(resource).to do_nothing
        expect(resource.cwd).to eq('/usr/share/doc/abiquo-server/database')
        expect(resource.command).to eq('abiquo-liquibase -h localhost -P 3306 -u root update')
        expect(resource).to notify('service[abiquo-tomcat]').to(:restart).delayed
    end

    it 'runs the liquibase update with custom attributes' do
        stub_command("/usr/bin/mysql -h 127.0.0.1 -P 3306 -u root -pabiquo kinton -e 'SELECT 1'").and_return(false)
        chef_run.node.set['abiquo']['db']['host'] = '127.0.0.1'
        chef_run.node.set['abiquo']['db']['password'] = 'abiquo'
        chef_run.converge('apache2::default', 'abiquo::install_server', described_recipe)
        resource = chef_run.find_resource(:execute, 'liquibase-update')
        expect(resource).to subscribe_to("package[abiquo-server]").on(:run).immediately
        expect(resource).to do_nothing
        expect(resource.cwd).to eq('/usr/share/doc/abiquo-server/database')
        expect(resource.command).to eq('abiquo-liquibase -h 127.0.0.1 -P 3306 -u root -p abiquo update')
        expect(resource).to notify('service[abiquo-tomcat]').to(:restart).delayed
    end

    %w{monolithic server kvm remoteservices v2v}.each do |profile|
        it "does not run abiquo watchtower liquibase update when upgrading #{profile}" do
            chef_run.node.set['abiquo']['db']['upgrade'] = true
            chef_run.node.set['abiquo']['profile'] = profile
            chef_run.converge('apache2::default', described_recipe, 'abiquo::service')
            expect(chef_run).to_not run_execute('run-watchtower-liquibase')
        end
    end

    it 'runs abiquo watchtower liquibase update when upgrading monitoring' do
        chef_run.converge('apache2::default', 'abiquo::install_server', described_recipe)
        resource = chef_run.find_resource(:execute, 'run-watchtower-liquibase')
        expect(resource).to subscribe_to("package[abiquo-server]").on(:run).immediately
        expect(resource).to do_nothing
        expect(resource.command).to eq('abiquo-watchtower-liquibase update')
    end

    %w{monolithic server}.each do |profile|
        it "starts the #{profile} services" do
            chef_run.node.set['abiquo']['profile'] = profile
            chef_run.converge('apache2::default', 'abiquo::install_server', described_recipe)
            expect(chef_run).to start_service('abiquo-tomcat')
            expect(chef_run).to_not start_service('abiquo-aim')
            expect(chef_run).to_not start_service('abiquo-delorean')
            expect(chef_run).to_not start_service('abiquo-emmett')
        end
    end

    %w{remoteservices v2v}.each do |profile|
        it "starts the #{profile} services" do
            chef_run.node.set['abiquo']['profile'] = profile
            # Remote Services and V2V do not need to include the install_server recipe
            chef_run.converge('apache2::default', described_recipe)
            expect(chef_run).to start_service('abiquo-tomcat')
            expect(chef_run).to_not start_service('abiquo-aim')
            expect(chef_run).to_not start_service('abiquo-delorean')
            expect(chef_run).to_not start_service('abiquo-emmett')
        end
    end

    it 'starts the kvm services' do
        chef_run.node.set['abiquo']['profile'] = 'kvm'
        chef_run.converge('apache2::default', described_recipe)
        expect(chef_run).to_not start_service('abiquo-tomcat')
        expect(chef_run).to_not start_service('abiquo-delorean')
        expect(chef_run).to_not start_service('abiquo-emmett')
        expect(chef_run).to start_service('abiquo-aim')
    end

    it 'starts the monitoring services' do
        chef_run.node.set['abiquo']['profile'] = 'monitoring'
        chef_run.converge('apache2::default', described_recipe)
        expect(chef_run).to_not start_service('abiquo-tomcat')
        expect(chef_run).to_not start_service('abiquo-aim')
        expect(chef_run).to start_service('abiquo-delorean')
        expect(chef_run).to start_service('abiquo-emmett')
    end

    %w(monolithic server).each do |profile|
        it "includes the #{profile} setup recipe" do
            chef_run.node.set['abiquo']['profile'] = profile
            chef_run.converge('apache2::default', described_recipe, 'abiquo::service', 'abiquo::install_server')
            expect(chef_run).to include_recipe("abiquo::setup_#{profile}")
        end
    end

    %w(remoteservices kvm monitoring v2v).each do |profile|
        it "includes the #{profile} setup recipe" do
            chef_run.node.set['abiquo']['profile'] = profile
            chef_run.converge('apache2::default', described_recipe, 'abiquo::service')
            expect(chef_run).to include_recipe("abiquo::setup_#{profile}")
        end
    end
end
