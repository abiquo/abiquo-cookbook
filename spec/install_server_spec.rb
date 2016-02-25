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

describe 'abiquo::install_server' do
    let(:chef_run) do
        ChefSpec::SoloRunner.new do |node|
            node.set['abiquo']['certificate']['common_name'] = 'test.local'
        end
    end
    let(:cn) { 'test.local' }

    before do
        stub_command('/usr/sbin/httpd -t').and_return(true)
        stub_command("/usr/bin/test -f /etc/pki/abiquo/#{cn}.crt").and_return(false)
        stub_command("/usr/bin/mysql -h localhost -P 3306 -u root kinton -e 'SELECT 1'").and_return(false)
        stub_command("rabbitmqctl list_users | egrep -q '^abiquo.*'").and_return(false)
    end

    it 'installs the Apache recipes' do
        chef_run.converge('apache2::default', described_recipe, 'abiquo::service')
        expect(chef_run).to include_recipe('apache2')
        expect(chef_run).to include_recipe('apache2::mod_proxy_ajp')
        expect(chef_run).to include_recipe('apache2::mod_ssl')
    end

    %w{liquibase jdk}.each do |pkg|
        it "installs the #{pkg} package" do
            chef_run.converge('apache2::default', described_recipe, 'abiquo::service')
            expect(chef_run).to install_package(pkg)
        end
    end

    %w{abiquo-server abiquo-sosreport-plugins abiquo-tutorials}.each do |pkg|
        it "installs the #{pkg} abiquo package" do
            chef_run.converge('apache2::default', described_recipe, 'abiquo::service')
            expect(chef_run).to install_package(pkg)
        end
    end

    it 'includes the certificate recipe' do
        chef_run.converge('apache2::default', described_recipe, 'abiquo::service')
        expect(chef_run).to include_recipe('abiquo::certificate')
    end

    # The apache webapp calls can be tested because it is not a LWRP
    # but a definition and does not exist in the resource list

    it 'includes the java oracle jce recipe' do
        chef_run.converge('apache2::default', described_recipe, 'abiquo::service')
        expect(chef_run).to include_recipe('java::oracle_jce')
    end

    it 'includes the install_ext_services recipe by default' do
        chef_run.converge('apache2::default', described_recipe, 'abiquo::service')
        expect(chef_run).to include_recipe('abiquo::install_ext_services')
    end

    it 'does not include install_ext_services recipe if not configured' do
        chef_run.node.set['abiquo']['install_ext_services'] = false
        chef_run.converge('apache2::default', described_recipe, 'abiquo::service')
        expect(chef_run).to_not include_recipe('abiquo::install_ext_services')
    end

    it 'includes the install-database recipe' do
        chef_run.converge('apache2::default', described_recipe, 'abiquo::service')
        expect(chef_run).to include_recipe('abiquo::install_database')
    end
end
