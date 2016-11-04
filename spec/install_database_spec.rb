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
require_relative 'support/queries'

describe 'abiquo::install_database' do
  let(:chef_run) { ChefSpec::SoloRunner.new }

  before do
    stub_queries
  end

  it 'installs the mysql2 gem' do
    chef_run.converge(described_recipe)
    expect(chef_run).to install_mysql2_chef_gem('server')
  end

  it 'creates the database' do
    chef_run.converge(described_recipe)
    expect(chef_run).to create_mysql_database('kinton')
  end

  it 'installs the database' do
    chef_run.converge(described_recipe)
    expect(chef_run).to_not run_execute('install-database')
    resource = chef_run.find_resource(:mysql_database, 'kinton')
    expect(resource).to notify('execute[install-database]').to(:run).immediately
  end

  it 'does not install the license if not provided' do
    chef_run.converge(described_recipe)
    expect(chef_run).to_not run_execute('install-license')
  end

  it 'does not install the license if it is empty' do
    chef_run.node.set['abiquo']['license'] = ''
    chef_run.converge(described_recipe)
    expect(chef_run).to_not query_mysql_database('install-license')
  end

  it 'installs the license if configured' do
    chef_run.node.set['abiquo']['license'] = 'foo'
    chef_run.converge(described_recipe)
    expect(chef_run).to_not query_mysql_database('install-license')
    resource = chef_run.find_resource(:execute, 'install-database')
    expect(resource).to notify('mysql_database[install-license]').to(:query).immediately
  end

  it 'extracts default m user password' do
    chef_run.converge(described_recipe)
    expect(chef_run).to_not run_ruby_block('extract-m-user-password')
    resource = chef_run.find_resource(:execute, 'install-database')
    expect(resource).to notify('ruby_block[extract-m-user-password]').to(:run).immediately
  end

  it 'does not remove extracted m user password if credential is present' do
    chef_run.node.set['abiquo']['properties']['abiquo.m.credential'] = 'blah'
    chef_run.converge(described_recipe)
    expect(chef_run).to_not run_ruby_block('extract-m-user-password')
  end

  it 'does not remove extracted m user password if access token is present' do
    chef_run.node.set['abiquo']['properties']['abiquo.m.accessToken'] = 'blah'
    chef_run.converge(described_recipe)
    expect(chef_run).to_not run_ruby_block('extract-m-user-password')
  end
end
