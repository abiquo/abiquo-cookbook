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
require_relative 'support/commands'
require_relative 'support/stubs'

describe 'abiquo::install_server' do
  before do
    stub_certificate_files('/etc/pki/abiquo/fauxhai.local.crt', '/etc/pki/abiquo/fauxhai.local.key')
    stub_command('/usr/sbin/httpd -t').and_return(true)
  end

  context 'when default' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.set['abiquo']['certificate']['common_name'] = 'fauxhai.local'
      end.converge(described_recipe, 'abiquo::service')
    end

    it 'installs the Apache recipes' do
      expect(chef_run).to include_recipe('apache2')
      expect(chef_run).to include_recipe('apache2::mod_proxy_ajp')
      expect(chef_run).to include_recipe('apache2::mod_ssl')
    end

    %w(liquibase jdk).each do |pkg|
      it "installs the #{pkg} package" do
        expect(chef_run).to install_package(pkg)
      end
    end

    %w(server sosreport-plugins).each do |pkg|
      it "installs the abiquo-#{pkg} abiquo package" do
        expect(chef_run).to install_package("abiquo-#{pkg}")
      end
    end

    it 'includes the java oracle jce recipe' do
      expect(chef_run).to include_recipe('java::oracle_jce')
    end

    it 'includes the install_ext_services recipe by default' do
      expect(chef_run).to include_recipe('abiquo::install_ext_services')
    end

    it 'includes the install database recipe' do
      expect(chef_run).to include_recipe('abiquo::install_database')
    end

    it 'includes the install frontend recipe' do
      expect(chef_run).to include_recipe('abiquo::install_frontend')
    end
  end

  context 'without ext serv and FE' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.set['abiquo']['certificate']['common_name'] = 'fauxhai.local'
        node.set['abiquo']['install_ext_services'] = false
        node.set['abiquo']['server']['install_frontend'] = false
      end.converge(described_recipe, 'abiquo::service')
    end

    it 'does not include install_ext_services recipe if not configured' do
      expect(chef_run).to_not include_recipe('abiquo::install_ext_services')
    end

    it 'does not install frontend components if configured' do
      expect(chef_run).to_not include_recipe('abiquo::install_frontend')
    end
  end
end
