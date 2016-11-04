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

describe 'abiquo::install_redis' do
  let(:chef_run) { ChefSpec::SoloRunner.new.converge(described_recipe) }

  it 'includes the redisio recipe' do
    expect(chef_run).to include_recipe('redisio')
  end

  it 'creates the redis user' do
    expect(chef_run).to create_user('redis').with(shell: '/bin/sh')
  end

  it 'includes the redisio::enable recipe' do
    expect(chef_run).to include_recipe('redisio::enable')
  end
end
