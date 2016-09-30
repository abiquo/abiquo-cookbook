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

describe 'Front-end configuration' do
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

    it 'has apache mappings to tomcat configured' do
        %w{api legal}.each do |webapp|
            expect(file('/etc/httpd/sites-available/abiquo.conf')).to contain("<Location /#{webapp}>")
            expect(file('/etc/httpd/sites-available/abiquo.conf')).to contain("ProxyPass ajp://localhost:8010/#{webapp}")
            expect(file('/etc/httpd/sites-available/abiquo.conf')).to contain("ProxyPassReverse ajp://localhost:8010/#{webapp}")
        end
        expect(file('/etc/httpd/sites-available/abiquo.conf')).to contain("ProxyPass http://localhost:8009/m")
    end

    it 'has ssl properly configured' do
        expect(file('/etc/httpd/sites-available/abiquo.conf')).to contain('SSLEngine on')
        expect(file('/etc/httpd/sites-available/abiquo.conf')).to contain('SSLProtocol all -SSLv2')
        expect(file('/etc/httpd/sites-available/abiquo.conf')).to contain('SSLCipherSuite ALL:!ADH:!EXPORT:!SSLv2:RC4+RSA:+HIGH:+MEDIUM:+LOW')
        expect(file('/etc/httpd/sites-available/abiquo.conf')).to contain('SSLCertificateFile /etc/pki/abiquo/frontend.abiquo.com.crt')
        expect(file('/etc/httpd/sites-available/abiquo.conf')).to contain('SSLCertificateKeyFile /etc/pki/abiquo/frontend.abiquo.com.key')
    end

    it 'has the ui properly configured' do
        expect(file('/var/www/html/ui/config/client-config-custom.json')).to exist
        # The suite is forced to configure the hostname
        expect(file('/var/www/html/ui/config/client-config-custom.json')).to contain('"client.backto.url": "http://google.com"')
        expect(file('/var/www/html/ui/config/client-config-custom.json')).to contain('"client.test.timeout": 600')
        expect(file('/var/www/html/ui/config/client-config-custom.json')).to contain('"config.endpoint": "https://server.abiquo.com/api"')
    end

    it 'has websockify service script configured' do
        expect(file('/etc/init.d/websockify')).to contain("WEBSOCKIFY_PORT=41337")
        expect(file('/etc/init.d/websockify')).to contain("CERT_FILE=/etc/pki/abiquo/frontend.abiquo.com.crt")
        expect(file('/etc/init.d/websockify')).to contain("KEY_FILE=/etc/pki/abiquo/frontend.abiquo.com.key")
    end

    it 'has haproxy service configured' do
        expect(file('/etc/haproxy/haproxy.cfg')).to contain("server websockify1 127.0.0.1:41338 weight 1 maxconn 1024 check")
        expect(file('/etc/haproxy/haproxy.cfg')).to contain("bind *:41337 ssl crt /etc/pki/abiquo/ws.abiquo.com.haproxy.crt")
    end

    it 'has novnc_tokens cron task configured' do
        expect(file('/etc/cron.d/novnc_tokens')).to_not be_executable
        expect(file('/etc/cron.d/novnc_tokens')).to contain("* * * * * root /opt/websockify/novnc_tokens.rb -a https://localhost/api -u admin -p xabiquo -f /opt/websockify/config.vnc")
    end
end
