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

describe 'abiquo::install_monitoring' do
    let(:chef_run) do
        ChefSpec::SoloRunner.new(file_cache_path: '/tmp') do |node|
            node.set['abiquo']['profile'] = 'monitoring'
        end.converge(described_recipe)
    end
    let(:pkg) { "kairosdb-#{chef_run.node['abiquo']['monitoring']['kairosdb']['version']}-#{chef_run.node['abiquo']['monitoring']['kairosdb']['release']}.rpm" }
    let(:url) { "https://github.com/kairosdb/kairosdb/releases/download/v#{chef_run.node['abiquo']['monitoring']['kairosdb']['version']}/#{pkg}" }

    before do
        stub_check_db_pass_command("root", "")
        stub_command("/usr/bin/mysql watchtower -e 'SELECT 1'").and_return(false)
        stub_check_db_pass_command(chef_run.node['abiquo']['db']['user'], chef_run.node['abiquo']['db']['password'])
    end

    it 'downloads the kairosdb package' do
        chef_run.converge(described_recipe)
        expect(chef_run).to create_remote_file("#{Chef::Config[:file_cache_path]}/#{pkg}").with({
            :source => url
        })
    end

    it 'installs the kairosdb package' do
        chef_run.converge(described_recipe)
        expect(chef_run).to install_package('kairosdb').with({
            :source => "#{Chef::Config[:file_cache_path]}/#{pkg}"
        })
    end

    it 'installs the jdk package' do
        chef_run.converge(described_recipe)
        expect(chef_run).to install_package('jdk')
    end

    it 'configures the java alternatives' do
        chef_run.converge(described_recipe)
        expect(chef_run).to set_java_alternatives('set default jdk8').with({
            :java_location => '/usr/java/default',
            :bin_cmds => ['java', 'javac']
        })
    end

    it 'includes the cassandra recipe' do
        chef_run.converge(described_recipe)
        expect(chef_run).to include_recipe('cassandra-dse')
    end

    it 'includes the install_ext_services recipe by default' do
        chef_run.converge(described_recipe)
        expect(chef_run).to include_recipe('abiquo::install_ext_services')
    end

    it 'does not include install_ext_services recipe if not configured' do
        chef_run.node.set['abiquo']['install_ext_services'] = false
        chef_run.converge(described_recipe)
        expect(chef_run).to_not include_recipe('abiquo::install_ext_services')
    end

    %w{delorean emmett}.each do |pkg|
        it "installs the abiquo-#{pkg} package" do
            chef_run.converge(described_recipe)
            expect(chef_run).to install_package("abiquo-#{pkg}")
        end
    end

    it 'installs the database by default' do
        chef_run.node.set['abiquo']['install_ext_services'] = false
        chef_run.converge(described_recipe)
        expect(chef_run).to install_package('MariaDB-client')
        expect(chef_run).to run_execute('create-watchtower-database').with(
            :command => '/usr/bin/mysql -e \'CREATE SCHEMA watchtower\''
        )
        
        resource = chef_run.execute('install-watchtower-database')
        expect(resource).to do_nothing
        expect(resource.command).to eq('/usr/bin/mysql watchtower < /usr/share/doc/abiquo-watchtower/database/src/watchtower-1.0.0.sql')
        expect(resource).to subscribe_to('execute[create-watchtower-database]').on(:run).delayed

        resource = chef_run.execute('run-watchtower-liquibase')
        expect(resource).to do_nothing
        expect(resource.command).to eq('abiquo-watchtower-liquibase -h localhost -P 3306 -u root update')
        expect(resource).to subscribe_to('execute[install-watchtower-database]').on(:run).delayed
    end

    it 'does not install the database if not configured' do
        chef_run.node.set['abiquo']['monitoring']['db']['install'] = false
        chef_run.node.set['abiquo']['install_ext_services'] = false
        chef_run.converge(described_recipe)
        expect(chef_run).to_not install_package('MariaDB-client')
    end
end
