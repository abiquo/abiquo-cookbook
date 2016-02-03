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

    it 'uninstalls mysql-libs package' do
        chef_run.converge(described_recipe)
        expect(chef_run).to purge_package('mysql-libs')
    end

    %w{monolithic server}.each do |profile|
        it "installs the #{profile} system packages" do
            chef_run.node.set['abiquo']['profile'] = profile
            chef_run.converge(described_recipe)
            %w{MariaDB-server MariaDB-client redis rabbitmq-server}.each do |pkg|
                expect(chef_run).to install_package(pkg)
            end
        end
        
        it "configures the #{profile} services" do
            chef_run.node.set['abiquo']['profile'] = profile
            chef_run.converge(described_recipe)
            %w{mysql rabbitmq-server redis}.each do |svc|
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
end
