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

    it 'creates the database' do
        expect(chef_run).to run_execute('create-database').with(
            :command => '/usr/bin/mysql -e "CREATE DATABASE IF NOT EXISTS kinton"'
        )
    end

    it 'installs the database' do
        expect(chef_run).to run_execute('install-database').with(
            :command => '/usr/bin/mysql kinton </usr/share/doc/abiquo-server/database/kinton-schema.sql'
        )
    end

    it 'does not install the license if not provided' do
        expect(chef_run).to_not run_execute('install-license')
    end

    it 'does not install the license if it is empty' do
        chef_run.node.set['abiquo']['license'] = ''
        expect(chef_run).to_not run_execute('install-license')
    end

    it 'installs the license if configured' do
        chef_run.node.set['abiquo']['license'] = 'foo'
        chef_run.converge(described_recipe)
        expect(chef_run).to run_execute('install-license').with(
            :command => '/usr/bin/mysql kinton -e "INSERT INTO license (data) VALUES (\'foo\');"'
        )
    end
end
