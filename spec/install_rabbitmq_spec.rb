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
  let(:chef_run) { ChefSpec::SoloRunner.new.converge(described_recipe, 'abiquo::service') }

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
end
