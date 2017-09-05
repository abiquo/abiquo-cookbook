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

    # it 'installs the mysql2 gem' do
    #   chef_run.converge(described_recipe)
    #   expect(chef_run).to install_mysql2_chef_gem('server')
    # end

    # Due to https://github.com/brianmario/mysql2/issues/878
    # mysql2 gem will not build with MariaDB 10.2 so we need
    # to install from git including the fix
    # TODO: Revert back to gem once the fix is merged and released.
    it 'installs the packages needed for build' do
      chef_run.converge(described_recipe)
      %w(git make gcc).each do |pkg|
        expect(chef_run).to install_package(pkg)
      end
    end

    it 'clones the mysql2 gem git repo' do
      chef_run.converge(described_recipe)
      expect(chef_run).to sync_git('/usr/local/src/mysql2-gem').with(
        repository: 'https://github.com/actsasflinn/mysql2',
        revision: 'f60600dae11d3cf629c1b895a4051e5572c13978'
      )
    end

    it 'builds the mysql2 gem from git' do
      chef_run.converge(described_recipe)
      expect(chef_run).to run_execute("#{RbConfig::CONFIG['bindir']}/gem build mysql2.gemspec").with(
        cwd: '/usr/local/src/mysql2-gem',
        creates: '/usr/local/src/mysql2-gem/mysql2-0.4.9.gem'
      )
    end

    it 'installs the mysql2 gem from git' do
      chef_run.converge(described_recipe)
      expect(chef_run).to install_chef_gem('mysql2').with(
        source: '/usr/local/src/mysql2-gem/mysql2-0.4.9.gem',
        compile_time: false
      )
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
