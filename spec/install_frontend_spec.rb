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
require_relative 'support/stubs'

describe 'abiquo::install_frontend' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new do |node|
      node.set['abiquo']['certificate']['common_name'] = 'fauxhai.local'
    end.converge('apache2::default', described_recipe, 'abiquo::service')
  end
  let(:cn) { 'fauxhai.local' }

  before do
    stub_certificate_files('/etc/pki/abiquo/fauxhai.local.crt', '/etc/pki/abiquo/fauxhai.local.key')
    stub_command('/usr/sbin/httpd -t').and_return(true)
    stub_command("/usr/bin/test -f /etc/pki/abiquo/#{cn}.crt").and_return(true)
    stub_command('/usr/bin/mysql kinton -e \'SELECT 1\'').and_return(true)
    stub_command('rabbitmqctl list_users | egrep -q \'^abiquo.*\'').and_return(false)
  end

  %w(ui websockify).each do |recipe|
    it "includes the #{recipe} install recipe" do
      expect(chef_run).to include_recipe("abiquo::install_#{recipe}")
    end
  end
end
