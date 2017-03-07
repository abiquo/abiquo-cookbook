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

describe 'Frontend configuration' do
  include_examples 'common::config'
  include_examples 'frontend::config'

  it 'has apache mappings to tomcat configured' do
    %w(api legal).each do |webapp|
      expect(file('/etc/httpd/sites-available/abiquo.conf')).to contain("<Location /#{webapp}>")
      expect(file('/etc/httpd/sites-available/abiquo.conf')).to contain("ProxyPass ajp://serverhost:8010/#{webapp}")
      expect(file('/etc/httpd/sites-available/abiquo.conf')).to contain("ProxyPassReverse ajp://serverhost:8010/#{webapp}")
    end
    expect(file('/etc/httpd/sites-available/abiquo.conf')).to contain('ProxyPass https://some_cms/blah')
    expect(file('/etc/httpd/sites-available/abiquo.conf')).to contain('ProxyPassReverse https://some_cms/blah')
    expect(file('/etc/httpd/sites-available/abiquo.conf')).to contain('Header add "Access-Control-Allow-Origin" "*"')
  end

  it 'has the ui properly configured' do
    expect(file('/var/www/html/ui/config/client-config-custom.json')).to contain('"client.backto.url": "http://google.com"')
    expect(file('/var/www/html/ui/config/client-config-custom.json')).to contain('"client.test.timeout": 600')
    expect(file('/var/www/html/ui/config/client-config-custom.json')).to contain('"config.endpoint": "https://server.abiquo.com/api"')
    expect(file('/var/www/html/ui/config/client-config-custom.json')).to contain('"client.google.maps.key": "trocotro"')
    expect(file('/var/www/html/ui/config/client-config-custom.json')).to contain('"client.test.timeout": 600')
    expect(file('/var/www/html/ui/config/client-config-custom.json')).to contain('"client.themes": [')
    expect(file('/var/www/html/ui/config/client-config-custom.json')).to contain('"abicloudDefault",')
    expect(file('/var/www/html/ui/config/client-config-custom.json')).to contain('"someothertheme"')
  end

  it 'has the right backends for the attributes' do
    expect(file('/etc/haproxy/haproxy.cfg')).to contain('acl _somepath path /somePath')
    expect(file('/etc/haproxy/haproxy.cfg')).to contain('acl _someotherpath path /someOtherPath')
    expect(file('/etc/haproxy/haproxy.cfg')).to contain('use_backend _somepath if _somepath')
    expect(file('/etc/haproxy/haproxy.cfg')).to contain('use_backend _someotherpath if _someotherpath')
    expect(file('/etc/haproxy/haproxy.cfg')).to contain('server websockify0 10.10.10.10:41338 weight 1 maxconn 1024 check')
    expect(file('/etc/haproxy/haproxy.cfg')).to contain('server websockify0 20.20.20.20:41338 weight 1 maxconn 1024 check')
  end

  it 'has the right backends for the search' do
    expect(file('/etc/haproxy/haproxy.cfg')).to contain('acl _edce1347bb2ea28a455769a1ea4c92449e5dc1ee path /edce1347bb2ea28a455769a1ea4c92449e5dc1ee')
    expect(file('/etc/haproxy/haproxy.cfg')).to contain('acl _b7cb0f38c6c7b16036802f3cd78e75f818bafab6 path /b7cb0f38c6c7b16036802f3cd78e75f818bafab6')
    expect(file('/etc/haproxy/haproxy.cfg')).to contain('use_backend _edce1347bb2ea28a455769a1ea4c92449e5dc1ee if _edce1347bb2ea28a455769a1ea4c92449e5dc1ee')
    expect(file('/etc/haproxy/haproxy.cfg')).to contain('use_backend _b7cb0f38c6c7b16036802f3cd78e75f818bafab6 if _b7cb0f38c6c7b16036802f3cd78e75f818bafab6')
    expect(file('/etc/haproxy/haproxy.cfg')).to contain('server websockify0 10.0.0.75:41338 weight 1 maxconn 1024 check')
    expect(file('/etc/haproxy/haproxy.cfg')).to contain('server websockify0 10.0.1.75:41338 weight 1 maxconn 1024 check')
  end
end
