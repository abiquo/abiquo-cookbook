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
end
