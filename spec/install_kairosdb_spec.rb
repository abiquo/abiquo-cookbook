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

shared_examples 'monitoring' do
  it 'enables the kairosdb service' do
    expect(chef_run).to enable_service('kairosdb')
  end

  it 'installs the kairosdb package' do
    expect(chef_run).to install_package('kairosdb')
  end
end

describe 'abiquo::install_kairosdb' do
  context 'when CentOS 7' do
    cached(:chef_run) { ChefSpec::SoloRunner.new.converge(described_recipe) }

    include_examples 'monitoring'
  end

  context 'when CentOS 6' do
    cached(:chef_run) { ChefSpec::SoloRunner.new(platform: 'centos', version: '6.5').converge(described_recipe) }

    include_examples 'monitoring'
  end
end
