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

describe 'abiquo::upgrade' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(file_cache_path: '/tmp', internal_locale: 'en_US.UTF-8') do |node|
      node.set['abiquo']['certificate']['common_name'] = 'fauxhai.local'
    end
  end

  before do
    stub_command('/usr/sbin/httpd -t').and_return(true)
    stub_command('service abiquo-tomcat stop').and_return(true)
    allow(::File).to receive(:executable?).with('/usr/bin/repoquery').and_return(true)
    allow(::File).to receive(:executable?).with('/sbin/initctl').and_return(false)
    stub_package_commands(['abiquo-api', 'abiquo-server'])
    stub_check_db_pass_command('root', '')
    stub_certificate_files('/etc/pki/abiquo/fauxhai.local.crt', '/etc/pki/abiquo/fauxhai.local.key')
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
    expect(chef_run).to write_log('Abiquo updates available.')
  end

  it 'logs a message if there are no upgrades' do
    stub_available_packages(['abiquo-api', 'abiquo-server'], '-0:3.6.1-85.el6.noarch')
    chef_run.converge('apache2::default', described_recipe)
    expect(chef_run).to write_log('No Abiquo updates found.')
  end

  it 'does nothing if no updates available' do
    stub_available_packages(['abiquo-api', 'abiquo-server'], '-0:3.6.1-85.el6.noarch')
    chef_run.converge('apache2::default', described_recipe)
    expect(chef_run.find_resource(:service, 'abiquo-tomcat')).to be_nil
    expect(chef_run.find_resource(:service, 'abiquo-aim')).to be_nil
    expect(chef_run.find_resource(:package, 'abiquo-api')).to be_nil
  end

  it 'performs upgrade if there are new rpms' do
    chef_run.converge('apache2::default', 'abiquo::install_websockify', described_recipe, 'abiquo::service', 'abiquo::install_server')
    expect(chef_run.find_resource(:service, 'abiquo-tomcat')).to_not be_nil
    expect(chef_run.find_resource(:service, 'abiquo-aim')).to be_nil
    expect(chef_run.find_resource(:package, 'abiquo-api')).to_not be_nil
  end

  %w(monolithic server).each do |profile|
    it "stops the #{profile} services" do
      chef_run.node.set['abiquo']['profile'] = profile
      chef_run.converge('apache2::default', 'abiquo::install_websockify', described_recipe, 'abiquo::service', 'abiquo::install_server')
      expect(chef_run).to stop_service('abiquo-tomcat')
      expect(chef_run).to_not stop_service('abiquo-aim')
      expect(chef_run).to_not stop_service('abiquo-delorean')
      expect(chef_run).to_not stop_service('abiquo-emmett')
      expect(chef_run).to stop_service('apache2')
      expect(chef_run).to stop_service('websockify')
    end
  end

  %w(remoteservices v2v).each do |profile|
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

  it 'stops the ui services' do
    chef_run.node.set['abiquo']['profile'] = 'ui'
    chef_run.converge('abiquo::install_websockify', 'abiquo::setup_websockify', described_recipe)
    expect(chef_run).to stop_service('apache2')
    expect(chef_run).to_not stop_service('websockify')
    expect(chef_run).to_not stop_service('abiquo-aim')
    expect(chef_run).to_not stop_service('abiquo-tomcat')
    expect(chef_run).to_not stop_service('abiquo-delorean')
    expect(chef_run).to_not stop_service('abiquo-emmett')
  end

  it 'stops the websockify services' do
    chef_run.node.set['abiquo']['profile'] = 'websockify'
    chef_run.converge('abiquo::install_websockify', 'abiquo::setup_websockify', described_recipe)
    expect(chef_run).to_not stop_service('apache2')
    expect(chef_run).to stop_service('websockify')
    expect(chef_run).to_not stop_service('abiquo-aim')
    expect(chef_run).to_not stop_service('abiquo-tomcat')
    expect(chef_run).to_not stop_service('abiquo-delorean')
    expect(chef_run).to_not stop_service('abiquo-emmett')
  end

  it 'includes the repository recipe' do
    chef_run.converge('apache2::default', 'abiquo::install_server', described_recipe)
    expect(chef_run).to include_recipe('abiquo::repository')
  end

  it 'upgrades the abiquo packages on monolithic' do
    chef_run.converge('apache2::default', 'abiquo::install_server', described_recipe)
    %w(abiquo-api abiquo-server).each do |pkg|
      expect(chef_run).to upgrade_package(pkg)
    end
  end

  it 'upgrades the abiquo packages on server' do
    chef_run.node.set['abiquo']['profile'] = 'server'
    chef_run.converge('apache2::default', 'abiquo::install_server', described_recipe)
    %w(abiquo-api abiquo-server).each do |pkg|
      expect(chef_run).to upgrade_package(pkg)
    end
  end

  it 'upgrades the abiquo packages on remoteservices' do
    stub_package_commands(['abiquo-virtualfactory', 'abiquo-remote-services'])
    chef_run.node.set['abiquo']['profile'] = 'remoteservices'
    chef_run.converge('apache2::default', described_recipe)
    %w(abiquo-virtualfactory abiquo-remote-services).each do |pkg|
      expect(chef_run).to upgrade_package(pkg)
    end
  end

  it 'upgrades the abiquo packages on kvm' do
    stub_package_commands(['abiquo-aim', 'abiquo-cloud-node'])
    chef_run.node.set['abiquo']['profile'] = 'kvm'
    chef_run.converge('apache2::default', described_recipe, 'abiquo::service')
    %w(abiquo-aim abiquo-cloud-node).each do |pkg|
      expect(chef_run).to upgrade_package(pkg)
    end
  end

  it 'upgrades the abiquo packages on monitoring' do
    stub_package_commands(['abiquo-delorean', 'abiquo-emmett'])
    chef_run.node.set['abiquo']['profile'] = 'monitoring'
    chef_run.converge('apache2::default', described_recipe, 'abiquo::service')
    %w(abiquo-delorean abiquo-emmett).each do |pkg|
      expect(chef_run).to upgrade_package(pkg)
    end
  end

  it 'does not run liquibase if not configured' do
    chef_run.node.set['abiquo']['db']['upgrade'] = false
    chef_run.node.set['abiquo']['profile'] = 'monolithic'
    chef_run.converge('apache2::default', 'abiquo::install_websockify', described_recipe, 'abiquo::install_server', 'abiquo::service')
    expect(chef_run).to_not run_execute('liquibase-update')
  end

  %w(kvm remoteservices monitoring v2v).each do |profile|
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
    expect(resource).to subscribe_to('package[abiquo-server]').on(:run).immediately
    expect(resource).to do_nothing
    expect(resource.cwd).to eq('/usr/share/doc/abiquo-model/database')
    expect(resource.command).to eq('abiquo-db -h localhost -P 3306 -u root update')
    expect(resource).to notify('service[abiquo-tomcat]').to(:restart).delayed
  end

  it 'runs the liquibase update with custom attributes' do
    stub_check_db_pass_command('root', 'abiquo', 'abiquo')
    stub_command('/usr/bin/mysql -h 127.0.0.1 -P 3306 -u root -pabiquo kinton -e \'SELECT 1\'').and_return(false)
    chef_run.node.set['abiquo']['db']['host'] = '127.0.0.1'
    chef_run.node.set['abiquo']['db']['password'] = 'abiquo'
    chef_run.converge('apache2::default', 'abiquo::install_server', described_recipe)
    resource = chef_run.find_resource(:execute, 'liquibase-update')
    expect(resource).to subscribe_to('package[abiquo-server]').on(:run).immediately
    expect(resource).to do_nothing
    expect(resource.cwd).to eq('/usr/share/doc/abiquo-model/database')
    expect(resource.command).to eq('abiquo-db -h 127.0.0.1 -P 3306 -u root -p abiquo update')
    expect(resource).to notify('service[abiquo-tomcat]').to(:restart).delayed
  end

  %w(monolithic server kvm remoteservices v2v).each do |profile|
    it "does not run abiquo watchtower liquibase update when upgrading #{profile}" do
      chef_run.node.set['abiquo']['db']['upgrade'] = true
      chef_run.node.set['abiquo']['install_ext_services'] = false
      chef_run.node.set['abiquo']['profile'] = profile
      chef_run.converge('apache2::default', 'abiquo::install_websockify', described_recipe, 'abiquo::service', 'abiquo::install_server')
      resource = chef_run.find_resource(:execute, 'watchtower-liquibase-update')
      expect(resource).to do_nothing
    end
  end

  it 'runs abiquo watchtower liquibase update when upgrading monitoring' do
    chef_run.node.set['abiquo']['profile'] = 'monitoring'
    chef_run.converge('apache2::default', 'abiquo::install_server', 'abiquo::service', described_recipe)
    resource = chef_run.find_resource(:execute, 'watchtower-liquibase-update')
    expect(resource).to do_nothing
    expect(resource.command).to eq('watchtower-db -h localhost -P 3306 -u root update')
    # We can't test this if there is no explicit resource notifying it, due to how ChefSpec subscription matchers are implemented
    # expect(resource).to subscribe_to('package[abiquo-delorean]')
    expect(resource).to notify('service[abiquo-delorean]').to(:restart).delayed
  end

  %w(monolithic server).each do |profile|
    it "starts the #{profile} services" do
      chef_run.node.set['abiquo']['profile'] = profile
      chef_run.converge('apache2::default', 'abiquo::install_server', 'abiquo::setup_websockify', described_recipe)
      expect(chef_run).to start_service('abiquo-tomcat')
      expect(chef_run).to_not start_service('abiquo-aim')
      expect(chef_run).to_not start_service('abiquo-delorean')
      expect(chef_run).to_not start_service('abiquo-emmett')
      expect(chef_run).to start_service('apache2')
      expect(chef_run).to start_service('websockify')
    end
  end

  %w(remoteservices v2v).each do |profile|
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

  it 'starts the ui services' do
    chef_run.node.set['abiquo']['profile'] = 'ui'
    chef_run.converge(described_recipe)
    expect(chef_run).to_not start_service('abiquo-tomcat')
    expect(chef_run).to_not start_service('abiquo-aim')
    expect(chef_run).to_not start_service('abiquo-delorean')
    expect(chef_run).to_not start_service('abiquo-emmett')
    expect(chef_run).to start_service('apache2')
    expect(chef_run).to_not start_service('websockify')
  end

  it 'starts the websockify services' do
    chef_run.node.set['abiquo']['profile'] = 'websockify'
    chef_run.converge('abiquo::install_websockify', 'abiquo::setup_websockify', described_recipe)
    expect(chef_run).to_not start_service('abiquo-tomcat')
    expect(chef_run).to_not start_service('abiquo-aim')
    expect(chef_run).to_not start_service('abiquo-delorean')
    expect(chef_run).to_not start_service('abiquo-emmett')
    expect(chef_run).to_not start_service('apache2')
    expect(chef_run).to start_service('websockify')
  end

  %w(monolithic server remoteservices kvm monitoring v2v).each do |profile|
    it "includes the default recipe for the #{profile} profile" do
      chef_run.node.set['abiquo']['profile'] = profile
      chef_run.converge(described_recipe)
      expect(chef_run).to include_recipe('abiquo::default')
    end
  end
end
