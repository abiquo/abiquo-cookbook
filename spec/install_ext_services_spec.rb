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

describe 'abiquo::install_ext_services' do
  cached(:chef_run) { ChefSpec::SoloRunner.new }

  before do
    stub_command('rabbitmqctl list_users | egrep -q \'^abiquo.*\'').and_return(false)
  end

  %w(monolithic server ext_services).each do |profile|
    context "when #{profile}" do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(file_cache_path: '/tmp') do |node|
          node.normal['abiquo']['profile'] = profile
        end.converge(described_recipe, 'abiquo::service')
      end

      it "includes the necessary recipes for #{profile}" do
        %w(mariadb redis rabbitmq).each do |recipe|
          expect(chef_run).to include_recipe("abiquo::install_#{recipe}")
        end
      end
    end
  end

  context 'when remoteservices' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(file_cache_path: '/tmp') do |node|
        node.normal['abiquo']['profile'] = 'remoteservices'
      end.converge(described_recipe)
    end

    it 'includes the necessary recipes for remoteservices' do
      expect(chef_run).to include_recipe('abiquo::install_redis')
    end
  end

  context 'when monitoring' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(file_cache_path: '/tmp') do |node|
        node.normal['abiquo']['profile'] = 'monitoring'
      end.converge(described_recipe)
    end

    it 'includes the necessary recipes for monitoring' do
      expect(chef_run).to include_recipe('abiquo::install_mariadb')
    end
  end
end
