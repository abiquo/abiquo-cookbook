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

describe 'abiquo::install_v2v' do
  let(:chef_run) { ChefSpec::SoloRunner.new.converge(described_recipe) }

  it 'installs the jdk package' do
    expect(chef_run).to install_package('jdk')
  end

  %w(abiquo-v2v redis abiquo-sosreport-plugins).each do |pkg|
    it "installs the #{pkg} abiquo package" do
      expect(chef_run).to install_package(pkg)
    end
  end

  # The apache webapp calls can be tested because it is not a LWRP
  # but a definition and does not exist in the resource list

  it 'includes the java oracle jce recipe' do
    expect(chef_run).to include_recipe('java::oracle_jce')
  end

  it 'configures the rpcbind service' do
    expect(chef_run).to enable_service('rpcbind')
    expect(chef_run).to start_service('rpcbind')
  end
end
