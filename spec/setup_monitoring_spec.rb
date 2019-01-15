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
  context 'whithout existing files' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.set['cassandra']['config']['cluster_name'] = 'abiquo'
        node.set['abiquo']['kairosdb_config']['kairosdb.datastore.cassandra.datapoint_ttl'] = 10
      end.converge('abiquo::service', 'abiquo::install_monitoring', described_recipe)
    end

    it 'renders the kairosdb configuration file' do
      expect(chef_run).to create_template('/opt/kairosdb/conf/kairosdb.properties').with(
        source: 'abiquo.properties.erb',
        owner: 'root',
        group: 'root'
      )

      expect(chef_run).to render_file('/opt/kairosdb/conf/kairosdb.properties').with_content(/^kairosdb.datastore.cassandra.datapoint_ttl\ =\ 10$/)
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

      it "renders the #{wts} configuration file" do
        expect(chef_run).to create_template("/etc/abiquo/watchtower/#{wts}.conf").with(
          source: 'watchtower-service.conf.erb',
          owner: 'root',
          group: 'root'
        )
      end

      it "renders the #{wts} properties file" do
        expect(chef_run).to create_template("/etc/abiquo/watchtower/#{wts}.properties").with(
          source: 'watchtower-service.properties.erb',
          owner: 'root',
          group: 'root'
        )
      end
    end
  end

  context 'with existing files' do
    before do
      allow(File).to receive(:exist?).and_call_original
      %w(delorean emmett).each do |wts|
        allow(File).to receive(:exist?).with("/etc/abiquo/watchtower/#{wts}-base.conf").and_return(true)
      end
    end

    cached(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.set['cassandra']['config']['cluster_name'] = 'abiquo'
      end.converge('abiquo::service', 'abiquo::install_monitoring', described_recipe)
    end

    %w(delorean emmett).each do |wts|
      it "avoids creating the #{wts} base file if already exists" do
        expect(chef_run).not_to create_file("/etc/abiquo/watchtower/#{wts}-base.conf")
      end
    end
  end
end
