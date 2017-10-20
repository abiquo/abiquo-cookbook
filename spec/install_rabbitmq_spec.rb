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

describe 'abiquo::install_rabbitmq' do
  context 'when default' do
    cached(:chef_run) { ChefSpec::SoloRunner.new.converge(described_recipe, 'abiquo::service') }

    it 'includes the rabbitmq recipe' do
      expect(chef_run).to include_recipe('rabbitmq')
    end

    it 'creates the Abiquo RabbitMQ user' do
      expect(chef_run).to add_rabbitmq_user(chef_run.node['abiquo']['rabbitmq']['username']).with(
        password: chef_run.node['abiquo']['rabbitmq']['password']
      )
    end

    it 'sets the apropraite tags to the Abiquo RabbitMQ user' do
      expect(chef_run).to set_tags_rabbitmq_user(chef_run.node['abiquo']['rabbitmq']['username']).with(
        tag: chef_run.node['abiquo']['rabbitmq']['tags']
      )
    end

    it 'creates the Abiquo RabbitMQ user' do
      expect(chef_run).to add_rabbitmq_user(chef_run.node['abiquo']['rabbitmq']['username']).with(
        vhost: chef_run.node['abiquo']['rabbitmq']['vhost'],
        permissions: '.* .* .*'
      )
    end

    it 'does not create a self signed certificate' do
      expect(chef_run).to_not create_ssl_certificate('rabbitmq-certificate')
      expect(chef_run).to_not import_java_management_truststore_certificate('rabbitmq-certificate')
    end
  end

  context 'when generate certificate' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.set['abiquo']['rabbitmq']['generate_cert'] = true
      end.converge(described_recipe, 'abiquo::service')
    end

    it 'creates a self signed certificate' do
      expect(chef_run).to create_ssl_certificate('rabbitmq-certificate').with(
        owner: 'rabbitmq',
        group: 'rabbitmq'
      )
      resource = chef_run.find_resource(:ssl_certificate, 'rabbitmq-certificate')
      expect(resource).to notify('service[rabbitmq-server]').to(:restart).delayed
      expect(resource).to notify('java_management_truststore_certificate[rabbitmq-certificate]').to(:import).immediately
    end

    it 'installs the certificate in the java trust store' do
      resource = chef_run.find_resource(:java_management_truststore_certificate, 'rabbitmq-certificate')
      expect(resource).to do_nothing
      expect(resource).to notify('service[abiquo-tomcat]').to(:restart).delayed
    end
  end
end
