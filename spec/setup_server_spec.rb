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
require_relative 'support/stubs'

describe 'abiquo::setup_server' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new do |node|
      node.set['abiquo']['certificate']['common_name'] = 'fauxhai.local'
    end
  end

  before do
    stub_queries
    stub_command('/usr/sbin/httpd -t').and_return(true)
    stub_command("/usr/bin/mysql kinton -e 'SELECT 1'").and_return(false)
    stub_certificate_files('/etc/pki/abiquo/fauxhai.local.crt', '/etc/pki/abiquo/fauxhai.local.key')
  end

  it 'includes the service recipe' do
    chef_run.converge('apache2::default', 'abiquo::install_server', described_recipe)
    expect(chef_run).to include_recipe('abiquo::service')
  end

  it 'includes the setup-ui recipe' do
    chef_run.converge('apache2::default', 'abiquo::install_server', described_recipe, 'abiquo::service')
    expect(chef_run).to include_recipe('abiquo::setup_ui')
  end

  it 'includes the setup-websockify recipe' do
    chef_run.converge('apache2::default', 'abiquo::install_server', described_recipe, 'abiquo::service')
    expect(chef_run).to include_recipe('abiquo::setup_websockify')
  end

  it 'renders API DB configuration file' do
    chef_run.converge('apache2::default', 'abiquo::install_server', described_recipe, 'abiquo::service')
    expect(chef_run).to create_template('/opt/abiquo/tomcat/conf/Catalina/localhost/api.xml').with(
      source: 'api-m.xml.erb',
      owner: 'root',
      group: 'root'
    )
    resource = chef_run.template('/opt/abiquo/tomcat/conf/Catalina/localhost/api.xml')
    expect(resource).to notify('service[abiquo-tomcat]').to(:restart).delayed
  end

  it 'renders M DB configuration file' do
    chef_run.converge('apache2::default', 'abiquo::install_server', described_recipe, 'abiquo::service')
    expect(chef_run).to create_template('/opt/abiquo/tomcat/conf/Catalina/localhost/m.xml').with(
      source: 'api-m.xml.erb',
      owner: 'root',
      group: 'root'
    )
    resource = chef_run.template('/opt/abiquo/tomcat/conf/Catalina/localhost/m.xml')
    expect(resource).to notify('service[abiquo-tomcat]').to(:restart).delayed
  end

  it 'does not configure frontend components if configured' do
    chef_run.node.set['abiquo']['server']['install_frontend'] = false
    chef_run.converge('apache2::default', described_recipe, 'abiquo::service')
    expect(chef_run).to_not include_recipe('abiquo::setup_websockify')
    expect(chef_run).to_not include_recipe('abiquo::setup_ui')
  end
end
