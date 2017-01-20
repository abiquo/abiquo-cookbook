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
require_relative 'support/commands'
require_relative 'support/queries'

describe 'abiquo::install_monitoring' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new do |node|
      node.set['abiquo']['profile'] = 'monitoring'
    end.converge(described_recipe)
  end

  before do
    stub_queries
  end

  it 'installs the kairosdb package' do
    expect(chef_run).to install_package('kairosdb')
  end

  it 'installs the jdk package' do
    expect(chef_run).to install_package('jdk')
  end

  it 'configures the java alternatives' do
    expect(chef_run).to set_java_alternatives('set default jdk8').with(
      java_location: '/usr/java/default',
      bin_cmds: %w(java javac)
    )
  end

  it 'includes the cassandra recipe' do
    expect(chef_run).to include_recipe('cassandra-dse')
  end

  it 'includes the install_ext_services recipe by default' do
    expect(chef_run).to include_recipe('abiquo::install_ext_services')
  end

  it 'does not include install_ext_services recipe if not configured' do
    chef_run.node.set['abiquo']['install_ext_services'] = false
    chef_run.converge(described_recipe)
    expect(chef_run).to_not include_recipe('abiquo::install_ext_services')
  end

  %w(delorean emmett).each do |pkg|
    it "installs the abiquo-#{pkg} package" do
      expect(chef_run).to install_package("abiquo-#{pkg}")
    end
  end

  it 'installs the database by default' do
    chef_run.node.set['abiquo']['install_ext_services'] = false
    chef_run.converge(described_recipe)
    expect(chef_run).to include_recipe('mariadb::client')
    expect(chef_run).to create_mysql_database('watchtower')

    expect(chef_run).to_not run_execute('install-watchtower-database')
    resource = chef_run.find_resource(:mysql_database, 'watchtower')
    expect(resource).to notify('execute[install-watchtower-database]').to(:run).immediately

    expect(chef_run).to_not run_execute('watchtower-liquibase-update')
    resource = chef_run.find_resource(:execute, 'install-watchtower-database')
    expect(resource).to notify('execute[watchtower-liquibase-update]').to(:run).immediately

    resource = chef_run.find_resource(:execute, 'watchtower-liquibase-update')
    expect(resource.command).to eq('watchtower-db -h localhost -P 3306 -u root update')
  end

  it 'does not install the database if not configured' do
    chef_run.node.set['abiquo']['monitoring']['db']['install'] = false
    chef_run.node.set['abiquo']['install_ext_services'] = false
    chef_run.converge(described_recipe)
    expect(chef_run).to_not query_mysql_database('watchtower')
  end
end
