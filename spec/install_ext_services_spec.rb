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
require_relative 'support/matchers'

describe 'abiquo::install_ext_services' do
    let(:chef_run) { ChefSpec::SoloRunner.new }

    it 'uninstalls mysql-libs package' do
        chef_run.converge(described_recipe)
        expect(chef_run).to purge_package('mysql-libs')
    end

    %w{MariaDB-server MariaDB-client redis rabbitmq-server}.each do |pkg|
        it "installs the #{pkg} system package" do
            chef_run.converge(described_recipe)
            expect(chef_run).to install_package(pkg)
        end
    end

    %w{mysql rabbitmq-server redis}.each do |svc|
        it "configures the #{svc} service" do
            chef_run.converge(described_recipe)
            expect(chef_run).to enable_service(svc)
            expect(chef_run).to start_service(svc)
        end
    end

end
