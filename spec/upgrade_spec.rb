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
require_relative 'support/commands'
require_relative 'support/stubs'

services = {
  'monolithic' => {
    'start' => ['abiquo-tomcat', 'apache2', 'guacd'],
    'not_start' => ['abiquo-aim', 'abiquo-delorean', 'abiquo-emmett'],
    'runs_liquibase' => true,
    'runs_wt_liquibase' => false },
  'server' => {
    'start' => ['abiquo-tomcat', 'apache2'],
    'not_start' => ['abiquo-aim', 'abiquo-delorean', 'abiquo-emmett'],
    'runs_liquibase' => true,
    'runs_wt_liquibase' => false },
  'v2v' => {
    'start' => ['abiquo-tomcat'],
    'not_start' => ['abiquo-aim', 'abiquo-delorean', 'abiquo-emmett'],
    'runs_liquibase' => false,
    'runs_wt_liquibase' => false },
  'remoteservices' => {
    'start' => ['abiquo-tomcat', 'guacd'],
    'not_start' => ['abiquo-aim', 'abiquo-delorean', 'abiquo-emmett'],
    'runs_liquibase' => false,
    'runs_wt_liquibase' => false },
  'kvm' => {
    'start' => ['abiquo-aim'],
    'not_start' => ['abiquo-tomcat', 'abiquo-delorean', 'abiquo-emmett'],
    'runs_liquibase' => false,
    'runs_wt_liquibase' => false },
  'monitoring' => {
    'start' => ['abiquo-delorean', 'abiquo-emmett'],
    'not_start' => ['abiquo-tomcat', 'abiquo-aim'],
    'runs_liquibase' => false,
    'runs_wt_liquibase' => true },
  'frontend' => {
    'start' => %w(apache2),
    'not_start' => ['abiquo-tomcat', 'abiquo-aim', 'abiquo-delorean', 'abiquo-emmett'],
    'runs_liquibase' => false,
    'runs_wt_liquibase' => false },
}

describe 'abiquo::upgrade' do
  # Tests for every profile
  services.each do |profile, srv|
    context "when #{profile}" do
      before do
        stub_command('/usr/sbin/httpd -t').and_return(true)
        allow(::File).to receive(:executable?).with(anything).and_call_original
        allow(::File).to receive(:executable?).with('/usr/bin/repoquery').and_return(true)
        stub_package_commands(['abiquo-api', 'abiquo-server', 'ec2-api-tools'])
      end

      cached(:chef_run) do
        ChefSpec::SoloRunner.new(file_cache_path: '/tmp') do |node|
          node.normal['abiquo']['profile'] = profile
          node.normal['abiquo']['certificate']['common_name'] = 'fauxhai.local'
        end.converge(described_recipe)
      end

      srv['start'].each do |s|
        it "should stop service #{s}" do
          expect(chef_run).to stop_service(s)
        end

        it "should start service #{s}" do
          expect(chef_run).to start_service(s)
        end
      end

      srv['not_start'].each do |s|
        it "should not stop service #{s}" do
          expect(chef_run).to_not stop_service(s)
        end

        it "should not start service #{s}" do
          expect(chef_run).to_not start_service(s)
        end
      end

      it "includes the default recipe for the #{profile} profile" do
        expect(chef_run).to include_recipe('abiquo::default')
      end
    end
  end

  context 'without repoquery' do
    before do
      allow(::File).to receive(:executable?).with('/usr/bin/repoquery').and_return(false)
    end

    cached(:chef_run) do
      ChefSpec::SoloRunner.new(file_cache_path: '/tmp') do |node|
        node.normal['abiquo']['certificate']['common_name'] = 'fauxhai.local'
      end.converge(described_recipe)
    end

    it 'does nothing if repoquery is not installed' do
      expect(chef_run.find_resource(:service, 'abiquo-tomcat')).to be_nil
      expect(chef_run.find_resource(:service, 'abiquo-aim')).to be_nil
      expect(chef_run.find_resource(:package, 'abiquo-api')).to be_nil
    end
  end

  context 'with default settings' do
    before do
      stub_command('/usr/sbin/httpd -t').and_return(true)
      allow(::File).to receive(:executable?).with(anything).and_call_original
      allow(::File).to receive(:executable?).with('/usr/bin/repoquery').and_return(true)
      stub_package_commands(['abiquo-api', 'abiquo-server', 'ec2-api-tools'])
    end

    cached(:chef_run) do
      ChefSpec::SoloRunner.new(file_cache_path: '/tmp') do |node|
        node.normal['abiquo']['certificate']['common_name'] = 'fauxhai.local'
      end.converge(described_recipe)
    end

    it 'includes the repository recipe' do
      expect(chef_run).to include_recipe('abiquo::repository')
    end

    context 'with no upgrades available' do
      before do
        stub_available_packages(['abiquo-api', 'abiquo-server', 'ec2-api-tools'], '-0:3.6.1-85.el6.noarch')
      end

      cached(:chef_run) do
        ChefSpec::SoloRunner.new(file_cache_path: '/tmp') do |node|
          node.normal['abiquo']['certificate']['common_name'] = 'fauxhai.local'
        end.converge(described_recipe)
      end

      it 'logs a message if there are no upgrades' do
        expect(chef_run).to write_log('No Abiquo updates found.')
      end

      it 'does nothing if no updates available' do
        expect(chef_run.find_resource(:service, 'abiquo-tomcat')).to be_nil
        expect(chef_run.find_resource(:service, 'abiquo-aim')).to be_nil
        expect(chef_run.find_resource(:package, 'abiquo-api')).to be_nil
      end
    end

    context 'with updates available' do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(file_cache_path: '/tmp') do |node|
          node.normal['abiquo']['certificate']['common_name'] = 'fauxhai.local'
        end.converge(described_recipe)
      end

      it 'logs a message if there are upgrades' do
        expect(chef_run).to write_log('Abiquo updates available.')
      end

      it 'performs upgrade if there are new rpms' do
        expect(chef_run.find_resource(:service, 'abiquo-tomcat')).to_not be_nil
        expect(chef_run.find_resource(:service, 'abiquo-aim')).to be_nil
        expect(chef_run.find_resource(:package, 'abiquo-api')).to_not be_nil
      end

      it 'upgrades the packages marked for upgrade' do
        %w(abiquo-api abiquo-server ec2-api-tools).each do |pkg|
          expect(chef_run).to upgrade_package(pkg)
        end
      end
    end
  end

  # Liquibase runs
  context 'with db update enabled' do
    services.each do |profile, srv|
      context "when #{profile}" do
        before do
          stub_command('/usr/sbin/httpd -t').and_return(true)
          allow(::File).to receive(:executable?).with(anything).and_call_original
          allow(::File).to receive(:executable?).with('/usr/bin/repoquery').and_return(true)
          stub_package_commands(['abiquo-api', 'abiquo-server', 'ec2-api-tools'])
        end

        cached(:chef_run) do
          ChefSpec::SoloRunner.new(file_cache_path: '/tmp') do |node|
            node.normal['abiquo']['profile'] = profile
            node.normal['abiquo']['certificate']['common_name'] = 'fauxhai.local'
          end.converge(described_recipe)
        end

        if srv['runs_liquibase']
          it 'runs the liquibase update command' do
            resource = chef_run.find_resource(:execute, 'liquibase-update')
            expect(resource).to subscribe_to('package[abiquo-server]').on(:run).immediately
            expect(resource).to notify('service[abiquo-tomcat]').to(:restart).delayed
          end
        else
          it 'does not run the liquibase update command' do
            expect(chef_run).to_not run_execute('liquibase-update')
          end
        end

        if srv['runs_wt_liquibase']
          it 'runs the watchtower liquibase update command' do
            resource = chef_run.find_resource(:execute, 'watchtower-liquibase-update')
            expect(resource).to subscribe_to('package[abiquo-delorean]').on(:run).immediately
            expect(resource).to notify('service[abiquo-delorean]').to(:restart).delayed
          end
        else
          it 'does not run the watchtower liquibase update command' do
            expect(chef_run).to_not run_execute('watchtower-liquibase-update')
          end
        end
      end
    end
  end

  context 'without db update enabled' do
    services.each do |profile, srv|
      context "when #{profile}" do
        before do
          stub_command('/usr/sbin/httpd -t').and_return(true)
          allow(::File).to receive(:executable?).with(anything).and_call_original
          allow(::File).to receive(:executable?).with('/usr/bin/repoquery').and_return(true)
          stub_package_commands(['abiquo-api', 'abiquo-server', 'ec2-api-tools'])
        end

        cached(:chef_run) do
          ChefSpec::SoloRunner.new(file_cache_path: '/tmp') do |node|
            node.normal['abiquo']['profile'] = profile
            node.normal['abiquo']['db']['upgrade'] = false
            node.normal['abiquo']['certificate']['common_name'] = 'fauxhai.local'
          end.converge(described_recipe)
        end

        it 'does not run the liquibase update command' do
          expect(chef_run).to_not run_execute('liquibase-update')
        end

        if srv['runs_wt_liquibase']
          it 'runs the watchtower liquibase update command' do
            resource = chef_run.find_resource(:execute, 'watchtower-liquibase-update')
            expect(resource).to subscribe_to('package[abiquo-delorean]').on(:run).immediately
            expect(resource).to notify('service[abiquo-delorean]').to(:restart).delayed
          end
        else
          it 'does not run the watchtower liquibase update command' do
            expect(chef_run).to_not run_execute('watchtower-liquibase-update')
          end
        end
      end
    end
  end
end
