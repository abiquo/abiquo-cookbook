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

describe 'abiquo::install_database' do
    let(:chef_run) { ChefSpec::SoloRunner.new.converge(described_recipe) }

    before do
        stub_command("/usr/bin/mysql -h localhost -P 3306 -uroot kinton -e 'SELECT 1'").and_return(false)
    end

    it 'creates the database' do
        expect(chef_run).to run_execute('create-database').with(
            :command => '/usr/bin/mysql -h localhost -P 3306 -uroot -e \'CREATE DATABASE kinton\''
        )
        resource = chef_run.execute('create-database')
        expect(resource).to notify("execute[install-database]").to(:run).immediately
    end

    it 'installs the database' do
        resource = chef_run.execute('install-database')
        expect(resource).to do_nothing
        expect(resource).to notify('ruby_block[extract_m_user_password]').to(:run).immediately
    end

    # it 'does not install the license if not provided' do
    #     expect(chef_run).to_not run_execute('install-license')
    # end

    # it 'does not install the license if it is empty' do
    #     chef_run.node.set['abiquo']['license'] = ''
    #     expect(chef_run).to_not run_execute('install-license')
    # end

    # it 'installs the license if configured' do
    #     chef_run.node.set['abiquo']['license'] = 'foo'
    #     chef_run.converge(described_recipe)
    #     expect(chef_run).to run_execute('install-license').with(
    #         :command => '/usr/bin/mysql kinton -e "INSERT INTO license (data) VALUES (\'foo\');"'
    #     )
    # end

    it 'extracts default m user password' do
        resource = chef_run.ruby_block('extract_m_user_password')
        expect(resource).to do_nothing  
    end
end
