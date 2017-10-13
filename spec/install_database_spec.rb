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
  before do
    stub_queries
  end

  context 'when default' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(file_cache_path: '/tmp') do |node|
        node.set['abiquo']['license'] = ''
        node.set['abiquo']['properties']['abiquo.m.credential'] = 'blah'
        node.set['abiquo']['properties']['abiquo.m.accessToken'] = 'blah'
      end.converge(described_recipe)
    end

    it 'installs the mysql2 gem' do
      chef_run.converge(described_recipe)
      expect(chef_run).to install_mysql2_chef_gem_mariadb('server')
    end

    it 'creates the database' do
      expect(chef_run).to create_mysql_database('kinton')
    end

    it 'installs the database' do
      expect(chef_run).to_not run_execute('install-database')
      resource = chef_run.find_resource(:mysql_database, 'kinton')
      expect(resource).to notify('execute[install-database]').to(:run).immediately
    end

    it 'does not install the license if not provided' do
      expect(chef_run).to_not run_execute('install-license')
    end

    it 'extracts default m user password' do
      expect(chef_run).to_not run_ruby_block('extract-m-user-password')
      resource = chef_run.find_resource(:execute, 'install-database')
      expect(resource).to notify('ruby_block[extract-m-user-password]').to(:run).immediately
    end

    it 'does not remove extracted m user password if credential is present' do
      expect(chef_run).to_not run_ruby_block('extract-m-user-password')
    end

    it 'does not remove extracted m user password if access token is present' do
      expect(chef_run).to_not run_ruby_block('extract-m-user-password')
    end
  end

  context 'when license is empty' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(file_cache_path: '/tmp') do |node|
        node.set['abiquo']['license'] = ''
      end.converge(described_recipe)
    end

    it 'does not install the license if it is empty' do
      expect(chef_run).to_not query_mysql_database('install-license')
    end
  end

  context 'when license exists' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(file_cache_path: '/tmp') do |node|
        node.set['abiquo']['license'] = 'foo'
      end.converge(described_recipe)
    end

    it 'installs the license if configured' do
      expect(chef_run).to_not query_mysql_database('install-license')
      resource = chef_run.find_resource(:execute, 'install-database')
      expect(resource).to notify('mysql_database[install-license]').to(:query).immediately
    end
  end
end
