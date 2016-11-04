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

describe 'abiquo::install_mariadb' do
  let(:chef_run) { ChefSpec::SoloRunner.new.converge(described_recipe) }

  before do
    stub_queries
  end

  it 'includes the mariadb recipe' do
    expect(chef_run).to include_recipe('mariadb')
  end

  it 'installs the mysql2 gem' do
    expect(chef_run).to install_mysql2_chef_gem('default')
  end

  it 'creates the Abiquo DB user' do
    expect(chef_run).to grant_mysql_database_user(chef_run.node['abiquo']['db']['user'])
    resource = chef_run.find_resource(:mysql_database_user, chef_run.node['abiquo']['db']['user'])
    expect(resource.password).to eq(chef_run.node['abiquo']['db']['password'])
    expect(resource.host).to eq(chef_run.node['abiquo']['db']['from'])
    expect(resource.privileges).to eq([:all])
  end

  it 'creates the Watchtower DB user' do
    expect(chef_run).to grant_mysql_database_user(chef_run.node['abiquo']['monitoring']['db']['user'])
    resource = chef_run.find_resource(:mysql_database_user, chef_run.node['abiquo']['monitoring']['db']['user'])
    expect(resource.password).to eq(chef_run.node['abiquo']['monitoring']['db']['password'])
    expect(resource.host).to eq(chef_run.node['abiquo']['monitoring']['db']['from'])
    expect(resource.privileges).to eq([:all])
  end
end
