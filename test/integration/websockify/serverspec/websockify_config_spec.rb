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

require "#{ENV['BUSSER_ROOT']}/../kitchen/data/serverspec_helper"

describe 'Websockify configuration' do
    it 'has the epel repos installed' do
        expect(file('/etc/yum.repos.d/epel.repo')).to be_file
        expect(file('/etc/yum.repos.d/epel.repo')).to contain("enabled=1")
    end
    
    it 'has the yum repositories configured' do
        %w{base updates}.each do |repo|
            expect(yumrepo("abiquo-#{repo}")).to exist
            expect(yumrepo("abiquo-#{repo}")).to be_enabled
        end
    end

    it 'has websockify service script configured' do
        expect(file('/etc/init.d/websockify')).to contain("WEBSOCKIFY_PORT=41337")
        expect(file('/etc/init.d/websockify')).to contain("CERT_FILE=/etc/pki/abiquo/ws.abiquo.com.crt")
        expect(file('/etc/init.d/websockify')).to contain("KEY_FILE=/etc/pki/abiquo/ws.abiquo.com.key")
    end

    it 'has novnc_tokens cron task configured' do
        expect(file('/etc/cron.d/novnc_tokens')).to_not be_executable
        expect(file('/etc/cron.d/novnc_tokens')).to contain("* * * * * root /opt/websockify/novnc_tokens.rb -a https://localhost/api -u admin -p xabiquo -f /opt/websockify/config.vnc")
    end
end
