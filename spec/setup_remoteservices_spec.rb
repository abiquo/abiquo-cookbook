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

describe 'abiquo::setup_remoteservices' do
    let(:chef_run) { ChefSpec::SoloRunner.new }

    it 'does not mount the nfs repository by default' do
        chef_run.converge(described_recipe)
        expect(chef_run).to_not mount_mount(chef_run.node['abiquo']['nfs']['mountpoint'])
    end

    it 'enables and mounts the nfs repository if configured' do
        chef_run.node.set['abiquo']['nfs']['location'] = '10.60.1.222:/opt/nfs-devel'
        chef_run.converge(described_recipe)
        expect(chef_run).to mount_mount('/opt/vm_repository').with(
            :fstype => 'nfs',
            :device => '10.60.1.222:/opt/nfs-devel'
        )
        expect(chef_run).to enable_mount('/opt/vm_repository').with(
            :fstype => 'nfs',
            :device => '10.60.1.222:/opt/nfs-devel'
        )
    end

    it 'defines the abiquo-tomcat-start service' do
        chef_run.converge(described_recipe)
        resource = chef_run.service('abiquo-tomcat-start')
        expect(resource).to do_nothing
    end

    it 'renders tomcat configuration file' do
        chef_run.converge(described_recipe)
        expect(chef_run).to create_template('/opt/abiquo/tomcat/conf/server.xml').with(
            :source => 'server.xml.erb',
            :owner => 'root',
            :group => 'root'
        )
        resource = chef_run.template('/opt/abiquo/tomcat/conf/server.xml')
        expect(resource).to notify('service[abiquo-tomcat-start]').to(:start).delayed
    end

    it 'renders abiquo properties file' do
        chef_run.converge(described_recipe)
        expect(chef_run).to create_template('/opt/abiquo/config/abiquo.properties').with(
            :source => 'abiquo-rs.properties.erb',
            :owner => 'root',
            :group => 'root'
        )
        resource = chef_run.template('/opt/abiquo/config/abiquo.properties')
        expect(resource).to notify('service[abiquo-tomcat-start]').to(:start).delayed
    end

    it 'waits until tomcat is started' do
        chef_run.node.set['abiquo']['tomcat']['wait-for-webapps'] = true
        chef_run.converge(described_recipe)
        resource = chef_run.find_resource(:abiquo_wait_for_webapp, 'virtualfactory')
        expect(resource).to do_nothing
        expect(resource).to subscribe_to('service[abiquo-tomcat-start]').on(:wait).delayed
    end
end
