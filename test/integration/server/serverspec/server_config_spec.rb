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

describe 'Server configuration' do
    it 'has the yum repositories configured' do
        %w{base updates}.each do |repo|
            expect(yumrepo("abiquo-#{repo}")).to exist
            expect(yumrepo("abiquo-#{repo}")).to be_enabled
        end
    end

    it 'has apache mappings to tomcat configured' do
        %w{api m legal}.each do |webapp|
            expect(file('/etc/httpd/sites-available/abiquo.conf')).to contain("<Location /#{webapp}>")
            expect(file('/etc/httpd/sites-available/abiquo.conf')).to contain("ProxyPass ajp://localhost:8010/#{webapp}")
            expect(file('/etc/httpd/sites-available/abiquo.conf')).to contain("ProxyPassReverse ajp://localhost:8010/#{webapp}")
        end
    end

    it 'has ssl properly configured' do
        expect(file('/etc/httpd/sites-available/abiquo.conf')).to contain('SSLEngine on')
        expect(file('/etc/httpd/sites-available/abiquo.conf')).to contain('SSLProtocol all -SSLv2')
        expect(file('/etc/httpd/sites-available/abiquo.conf')).to contain('SSLCipherSuite ALL:!ADH:!EXPORT:!SSLv2:RC4+RSA:+HIGH:+MEDIUM:+LOW')
        expect(file('/etc/httpd/sites-available/abiquo.conf')).to contain('SSLCertificateFile /usr/var/ssl/certs/server.crt')
        expect(file('/etc/httpd/sites-available/abiquo.conf')).to contain('SSLCertificateKeyFile /usr/var/ssl/certs/server.key')
    end

    it 'has the ui config file' do
        expect(file('/var/www/html/ui/config/client-config-custom.json')).to exist
    end

    it 'has tomcat properly configured' do
        expect(file('/opt/abiquo/tomcat/conf/server.xml')).to contain('<Listener className="com.abiquo.listeners.AbiquoConfigurationListener"/>')
    end

    it 'has the abiquo properties file' do
        expect(file('/opt/abiquo/config/abiquo.properties')).to exist
    end
end
