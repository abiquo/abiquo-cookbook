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

describe 'abiquo::install_ext_services' do
    let(:chef_run) { ChefSpec::SoloRunner.new }

    before do
        stub_command("rabbitmqctl list_users | egrep -q '^abiquo.*'").and_return(false)
    end

    it 'uninstalls mysql-libs package' do
        chef_run.converge(described_recipe)
        expect(chef_run).to purge_package('mysql-libs')
    end

    %w{monolithic server}.each do |profile|
        it "installs the #{profile} system packages" do
            chef_run.node.set['abiquo']['profile'] = profile
            chef_run.converge(described_recipe)
            %w{MariaDB-server MariaDB-client redis rabbitmq-server cronie}.each do |pkg|
                expect(chef_run).to install_package(pkg)
            end
        end

        it "configures the #{profile} services" do
            chef_run.node.set['abiquo']['profile'] = profile
            chef_run.converge(described_recipe)
            %w{mysql rabbitmq-server redis crond}.each do |svc|
                expect(chef_run).to enable_service(svc)
                expect(chef_run).to start_service(svc)
            end
        end
    end

    it "installs the remoteservices system packages" do
        chef_run.node.set['abiquo']['profile'] = "remoteservices"
        chef_run.converge(described_recipe)
        expect(chef_run).to install_package("redis")
    end

    it "configures the remoteservices services" do
        chef_run.node.set['abiquo']['profile'] = "remoteservices"
        chef_run.converge(described_recipe)
        expect(chef_run).to enable_service("redis")
        expect(chef_run).to start_service("redis")
    end

    it "installs the monitoring system packages" do
        chef_run.node.set['abiquo']['profile'] = "monitoring"
        chef_run.converge(described_recipe)
        %w{MariaDB-server MariaDB-client}.each do |pkg|
            expect(chef_run).to install_package(pkg)
        end
    end

    it "configures the monitoring services" do
        chef_run.node.set['abiquo']['profile'] = "monitoring"
        chef_run.converge(described_recipe)
        expect(chef_run).to enable_service("mysql")
        expect(chef_run).to start_service("mysql")
    end

    it "creates a rabbit user and sets the permissions" do
        chef_run.converge(described_recipe)

        resource = chef_run.find_resource(:execute, 'create-abiquo-rabbit-user')
        expect(resource).to do_nothing
        expect(resource.command).to eq('rabbitmqctl add_user abiquo abiquo')
        expect(resource).to subscribe_to('service[rabbitmq-server]').on(:run).delayed

        resource = chef_run.find_resource(:execute, 'set-abiquo-rabbit-user-administrator')
        expect(resource).to do_nothing
        expect(resource.command).to eq('rabbitmqctl set_user_tags abiquo administrator')
        expect(resource).to subscribe_to('execute[create-abiquo-rabbit-user]').on(:run).delayed

        resource = chef_run.find_resource(:execute, 'set-abiquo-rabbit-user-permissions')
        expect(resource).to do_nothing
        expect(resource.command).to eq("rabbitmqctl set_permissions -p / abiquo '.*' '.*' '.*'")
        expect(resource).to subscribe_to('execute[create-abiquo-rabbit-user]').on(:run).delayed
    end
end
