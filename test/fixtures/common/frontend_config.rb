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

shared_examples 'frontend::config' do
  it 'renders Apache directives in config file' do
    expect(file('/etc/httpd/sites-available/abiquo.conf')).to contain('KeepAlive On')
    expect(file('/etc/httpd/sites-available/abiquo.conf')).to contain('MaxKeepAliveRequests 100')
    expect(file('/etc/httpd/sites-available/abiquo.conf')).to contain('KeepAliveTimeout 60')
  end

  it 'has ssl properly configured' do
    expect(file('/etc/httpd/sites-available/abiquo.conf')).to contain('SSLEngine on')
    expect(file('/etc/httpd/sites-available/abiquo.conf')).to contain('SSLProtocol All -SSLv2 -SSLv3')
    expect(file('/etc/httpd/sites-available/abiquo.conf')).to contain('SSLCipherSuite EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH')
    expect(file('/etc/httpd/sites-available/abiquo.conf')).to contain('SSLCertificateFile /etc/pki/abiquo/frontend.bcn.abiquo.com.crt')
    expect(file('/etc/httpd/sites-available/abiquo.conf')).to contain('SSLCertificateKeyFile /etc/pki/abiquo/frontend.bcn.abiquo.com.key')
  end

  it 'has the ui properly configured' do
    expect(file('/var/www/html/ui/config/client-config-custom.json')).to exist
    expect(file('/var/www/html/ui/config/client-config-custom.json')).to contain('"config.endpoint": "https://')
  end
end
