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

describe 'abiquo::install_remoteservices' do
  cached(:chef_run) do
    ChefSpec::SoloRunner.new(internal_locale: 'en_US.UTF-8') do |node|
      node.set['abiquo']['certificate']['common_name'] = 'fauxhai.local'
    end.converge(described_recipe, 'abiquo::service')
  end

  it 'includes needed recipes' do
    %w(java::oracle_jce abiquo::install_ext_services abiquo::certificate).each do |recipe|
      expect(chef_run).to include_recipe(recipe)
    end
  end

  it 'installs the jdk system package' do
    expect(chef_run).to install_package('jdk')
  end

  %w(abiquo-remote-services abiquo-sosreport-plugins).each do |pkg|
    it "installs the #{pkg} abiquo package" do
      expect(chef_run).to install_package(pkg)
    end
  end

  it 'configures the rpcbind service' do
    expect(chef_run).to enable_service('rpcbind')
    expect(chef_run).to start_service('rpcbind')
  end

  it 'configures the guacd service' do
    expect(chef_run).to enable_service('guacd')
    expect(chef_run).to start_service('guacd')
  end
end
