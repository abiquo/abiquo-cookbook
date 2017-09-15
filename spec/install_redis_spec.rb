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
  let(:c6_run) { ChefSpec::SoloRunner.new(file_cache_path: '/tmp', platform: 'centos', version: '6.5').converge(described_recipe) }

  it 'creates the redis user' do
    expect(chef_run).to create_user('redis').with(
      comment: 'Redis Server',
      home: '/var/lib/redis',
      shell: '/bin/sh',
      system: true
    )

    expect(c6_run).to create_user('redis').with(
      comment: 'Redis Server',
      home: '/var/lib/redis',
      shell: '/bin/sh',
      system: true
    )
  end

  it 'creates selinux module in CentOS 6' do
    semodule_filename_base = 'redis_sentinel'
    semodule_filepath_base = "#{Chef::Config[:file_cache_path]}/#{semodule_filename_base}"
    semodule_filepath = "#{semodule_filepath_base}.te"
    expect(c6_run).to create_file(semodule_filepath)

    resource = c6_run.find_resource(:file, semodule_filepath)
    expect(resource).to notify("execute[semodule-install-#{semodule_filename_base}]").to(:run).immediately

    resource = c6_run.find_resource(:execute, "semodule-install-#{semodule_filename_base}")
    expect(resource).to do_nothing
  end

  it 'includes the redisio recipe' do
    expect(chef_run).to include_recipe('redisio')
    expect(c6_run).to include_recipe('redisio')
  end

  it 'includes the redisio::enable recipe' do
    expect(chef_run).to include_recipe('redisio::enable')
    expect(c6_run).to include_recipe('redisio')
  end
end
