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

describe 'abiquo::install_monolithic' do
    let(:chef_run) { ChefSpec::SoloRunner.new do |node|
        node.set['abiquo']['certificate']['common_name'] = 'test.local'
    end.converge('apache2::default',described_recipe,'abiquo::service') }
    let(:cn) { 'test.local' }
    
    before do
        stub_command('/usr/sbin/httpd -t').and_return(true)
        stub_command("/usr/bin/test -f /etc/pki/abiquo/#{cn}.crt").and_return(true)
        stub_command("/usr/bin/mysql -h localhost -P 3306 -uroot kinton -e 'SELECT 1'").and_return(true)
    end

    %w{server remoteservices v2v}.each do |recipe|
        it "includes the #{recipe} install recipe" do
            expect(chef_run).to include_recipe("abiquo::install_#{recipe}")
        end
    end
end
