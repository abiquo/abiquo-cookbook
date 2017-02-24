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

describe 'abiquo::service' do
  let(:chef_run) { ChefSpec::SoloRunner.new }

  before do
    stub_check_db_pass_command('root', '')
  end

  it 'defines the abiquo-tomcat service' do
    chef_run.converge(described_recipe)
    expect(chef_run).to enable_service('abiquo-tomcat')
    expect(chef_run).to start_service('abiquo-tomcat')

    resource = chef_run.find_resource(:service, 'abiquo-tomcat')
    expect(resource).to_not subscribe_to("rabbitmq_user[#{chef_run.node['abiquo']['rabbitmq']['username']}]")
  end

  it 'subscribes to restart if rabbit configuration changed' do
    stub_command('rabbitmqctl list_users | egrep -q \'^abiquo.*\'').and_return(false)
    chef_run.converge('abiquo::install_ext_services', described_recipe)

    resource = chef_run.find_resource(:service, 'abiquo-tomcat')
    expect(resource).to subscribe_to("rabbitmq_user[#{chef_run.node['abiquo']['rabbitmq']['username']}]").on(:restart)
  end

  it 'renders tomcat configuration file' do
    chef_run.converge(described_recipe)
    expect(chef_run).to create_template('/opt/abiquo/tomcat/conf/server.xml').with(
      source: 'server.xml.erb',
      owner: 'tomcat',
      group: 'root'
    )

    resource = chef_run.template('/opt/abiquo/tomcat/conf/server.xml')
    expect(resource).to notify('service[abiquo-tomcat]').to(:restart).delayed
  end

  it 'renders abiquo default properties file' do
    chef_run.converge(described_recipe)
    expect(chef_run).to create_template('/opt/abiquo/config/abiquo.properties').with(
      source: 'abiquo.properties.erb',
      owner: 'root',
      group: 'root'
    )
    resource = chef_run.template('/opt/abiquo/config/abiquo.properties')
    expect(resource).to notify('service[abiquo-tomcat]').to(:restart).delayed
    expect(chef_run).to render_file('/opt/abiquo/config/abiquo.properties').with_content(/^abiquo.rabbitmq.host\ =\ 127.0.0.1/)
  end

  it 'renders abiquo properties file with custom properties' do
    chef_run.node.set['abiquo']['properties']['abiquo.docker.registry'] = 'http://localhost:5000'
    chef_run.node.set['abiquo']['properties']['foo'] = 'bar'

    chef_run.converge(described_recipe)
    expect(chef_run).to create_template('/opt/abiquo/config/abiquo.properties').with(
      source: 'abiquo.properties.erb',
      owner: 'root',
      group: 'root'
    )
    resource = chef_run.template('/opt/abiquo/config/abiquo.properties')
    expect(resource).to notify('service[abiquo-tomcat]').to(:restart).delayed
    expect(chef_run).to render_file('/opt/abiquo/config/abiquo.properties').with_content(%r{^abiquo.docker.registry\ =\ http:\/\/localhost:5000})
  end

  it 'waits for API on monolithic' do
    chef_run.node.set['abiquo']['tomcat']['wait-for-webapps'] = true
    chef_run.converge(described_recipe)
    resource = chef_run.find_resource(:abiquo_wait_for_webapp, 'api')
    expect(resource).to do_nothing
    expect(resource).to subscribe_to('service[abiquo-tomcat]').on(:wait).delayed
  end

  it 'waits for API on server' do
    chef_run.node.set['abiquo']['tomcat']['wait-for-webapps'] = true
    chef_run.node.set['abiquo']['profile'] = 'server'
    chef_run.converge(described_recipe)
    resource = chef_run.find_resource(:abiquo_wait_for_webapp, 'api')
    expect(resource).to do_nothing
    expect(resource).to subscribe_to('service[abiquo-tomcat]').on(:wait).delayed
  end

  it 'waits for virtualfactory on remoteservices' do
    chef_run.node.set['abiquo']['tomcat']['wait-for-webapps'] = true
    chef_run.node.set['abiquo']['profile'] = 'remoteservices'
    chef_run.converge(described_recipe)
    resource = chef_run.find_resource(:abiquo_wait_for_webapp, 'virtualfactory')
    expect(resource).to do_nothing
    expect(resource).to subscribe_to('service[abiquo-tomcat]').on(:wait).delayed
  end

  it 'waits for bpm-async on v2v' do
    chef_run.node.set['abiquo']['tomcat']['wait-for-webapps'] = true
    chef_run.node.set['abiquo']['profile'] = 'v2v'
    chef_run.converge(described_recipe)
    resource = chef_run.find_resource(:abiquo_wait_for_webapp, 'bpm-async')
    expect(resource).to do_nothing
    expect(resource).to subscribe_to('service[abiquo-tomcat]').on(:wait).delayed
  end
end
