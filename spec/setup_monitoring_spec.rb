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

describe 'abiquo::setup_monitoring' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new do |node|
      node.set['cassandra']['config']['cluster_name'] = 'abiquo'
    end.converge('cassandra-dse', described_recipe)
  end

  it 'declares the kairosdb service' do
    resource = chef_run.service('kairosdb')
    expect(resource).to do_nothing
  end

  it 'renders the kairosdb configuration file' do
    expect(chef_run).to create_template('/opt/kairosdb/conf/kairosdb.properties').with(
      source: 'kairosdb.properties.erb',
      owner: 'root',
      group: 'root'
    )
  end

  it 'reboots kairosdb when cassandra is started' do
    resource = chef_run.find_resource(:abiquo_wait_for_port, 'cassandra')
    expect(resource).to do_nothing
    expect(resource).to subscribe_to('service[cassandra]').on(:wait).delayed
    expect(resource).to notify('service[kairosdb]').to(:restart).delayed
  end

  %w(delorean emmett).each do |wts|
    it "enables the abiquo-#{wts} service" do
      expect(chef_run).to enable_service("abiquo-#{wts}")
      resource = chef_run.service("abiquo-#{wts}")
      expect(resource).to subscribe_to('service[kairosdb]').on(:restart).delayed
    end

    it "creates the #{wts} base file" do
      expect(chef_run).to create_file("/etc/abiquo/watchtower/#{wts}-base.conf").with(
        owner: 'root',
        group: 'root'
      )
    end

    it "avoids creating the #{wts} base file if already exists" do
      allow(File).to receive(:exist?).and_call_original
      allow(File).to receive(:exist?).with("/etc/abiquo/watchtower/#{wts}-base.conf").and_return(true)
      expect(chef_run).not_to create_file("/etc/abiquo/watchtower/#{wts}-base.conf")
    end

    it "renders the #{wts} configuration file" do
      expect(chef_run).to create_template("/etc/abiquo/watchtower/#{wts}.conf").with(
        source: 'watchtower-service.conf.erb',
        owner: 'root',
        group: 'root'
      )
    end
  end
end
