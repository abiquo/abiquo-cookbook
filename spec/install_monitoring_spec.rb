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

describe 'abiquo::install_monitoring' do
    let(:chef_run) do
        ChefSpec::SoloRunner.new(file_cache_path: '/tmp') do |node|
            node.set['abiquo']['profile'] = 'monitoring'
            node.set['abiquo']['monitoring']['db']['password'] = 'pass'
        end
    end
    let(:pkg) { "kairosdb-#{chef_run.node['abiquo']['monitoring']['kairosdb']['version']}-#{chef_run.node['abiquo']['monitoring']['kairosdb']['release']}.rpm" }
    let(:url) { "https://github.com/kairosdb/kairosdb/releases/download/v#{chef_run.node['abiquo']['monitoring']['kairosdb']['version']}/#{pkg}" }

    before do
        stub_command("/usr/bin/mysql -h localhost -P 3306 -u root -ppass watchtower -e 'SELECT 1'").and_return(false)
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
            :command => '/usr/bin/mysql -h localhost -P 3306 -u root -ppass -e \'CREATE SCHEMA watchtower\''
        )

        resource = chef_run.find_resource(:execute, 'install-watchtower-database')
        expect(resource).to subscribe_to('execute[create-watchtower-database]').on(:run).delayed
        expect(resource).to do_nothing
        
        resource = chef_run.find_resource(:execute, 'run-watchtower-liquibase')
        expect(resource).to subscribe_to('execute[install-watchtower-database]').on(:run).delayed
        expect(resource).to do_nothing
    end

    it 'does not install the database if not configured' do
        chef_run.node.set['abiquo']['monitoring']['db']['install'] = false
        chef_run.node.set['abiquo']['install_ext_services'] = false
        chef_run.converge(described_recipe)
        expect(chef_run).to_not install_package('MariaDB-client')
        expect(chef_run).to_not run_execute('create-watchtower-database')

        resource = chef_run.find_resource(:execute, 'create-watchtower-database')
        expect(resource).to_not notify('execute[install-watchtower-database]').to(:run).delayed
    end
end
