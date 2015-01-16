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

describe 'abiquo::upgrade' do
    let(:chef_run) { ChefSpec::SoloRunner.new }

    it 'restarts the monolithic services' do
        chef_run.node.set['abiquo']['profile'] = 'monolithic'
        chef_run.converge(described_recipe)

        expect(chef_run).to stop_service('abiquo-tomcat')
        expect(chef_run).to stop_service('redis')
        expect(chef_run).to stop_service('mysql')
        expect(chef_run).to stop_service('rabbitmq-server')

        expect(chef_run).to start_service('abiquo-tomcat')
        expect(chef_run).to start_service('redis')
        expect(chef_run).to start_service('mysql')
        expect(chef_run).to start_service('rabbitmq-server')

        expect(chef_run).to_not stop_service('abiquo-aim')
        expect(chef_run).to_not start_service('abiquo-aim')
    end

    it 'restarts the remoteservices services' do
        chef_run.node.set['abiquo']['profile'] = 'remoteservices'
        chef_run.converge(described_recipe)

        expect(chef_run).to stop_service('abiquo-tomcat')
        expect(chef_run).to stop_service('redis')
        expect(chef_run).to_not stop_service('mysql')
        expect(chef_run).to_not stop_service('rabbitmq-server')

        expect(chef_run).to start_service('abiquo-tomcat')
        expect(chef_run).to start_service('redis')
        expect(chef_run).to_not start_service('mysql')
        expect(chef_run).to_not start_service('rabbitmq-server')

        expect(chef_run).to_not stop_service('abiquo-aim')
        expect(chef_run).to_not start_service('abiquo-aim')
    end

    it 'restarts the kvm services' do
        chef_run.node.set['abiquo']['profile'] = 'kvm'
        chef_run.converge(described_recipe)

        expect(chef_run).to_not stop_service('abiquo-tomcat')
        expect(chef_run).to_not stop_service('redis')
        expect(chef_run).to_not stop_service('mysql')
        expect(chef_run).to_not stop_service('rabbitmq-server')

        expect(chef_run).to_not start_service('abiquo-tomcat')
        expect(chef_run).to_not start_service('redis')
        expect(chef_run).to_not start_service('mysql')
        expect(chef_run).to_not start_service('rabbitmq-server')

        expect(chef_run).to stop_service('abiquo-aim')
        expect(chef_run).to start_service('abiquo-aim')
    end

    it 'includes the repository recipe' do
        chef_run.converge(described_recipe)
        expect(chef_run).to include_recipe('abiquo::repository')
    end

    it 'upgrades the abiquo packages' do
        chef_run.converge(described_recipe)
        expect(chef_run).to run_execute('yum-upgrade-abiquo').with(
            :command => 'yum -y upgrade abiquo-*'
        )
    end
end
