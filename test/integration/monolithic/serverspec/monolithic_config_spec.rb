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

describe 'Monolithic configuration' do
  it 'has the epel repos installed' do
    expect(file('/etc/yum.repos.d/epel.repo')).to be_file
    expect(file('/etc/yum.repos.d/epel.repo')).to contain('enabled=1')
  end

  it 'has the yum repositories configured' do
    %w(base updates).each do |repo|
      expect(yumrepo("abiquo-#{repo}")).to exist
      expect(yumrepo("abiquo-#{repo}")).to be_enabled
    end
  end

  it 'has websockify service script configured' do
    config_file = os[:release].to_i == 6 ? '/etc/init.d/websockify' : '/etc/sysconfig/websockify'
    expect(file(config_file)).to contain('WEBSOCKIFY_PORT=41338')
    expect(file(config_file)).to contain('LOG_FILE=/var/log/websockify')
  end

  it 'has the config file for the websockify plugin' do
    expect(file('/opt/websockify/abiquo.cfg')).to contain('[websockify]')
    expect(file('/opt/websockify/abiquo.cfg')).to contain('ssl_verify = false')
    expect(file('/opt/websockify/abiquo.cfg')).to contain('api_user = admin')
    expect(file('/opt/websockify/abiquo.cfg')).to contain('api_pass = xabiquo')
  end

  it 'has haproxy service configured' do
    expect(file('/etc/haproxy/haproxy.cfg')).to contain('server websockify1 127.0.0.1:41338 weight 1 maxconn 1024 check')
    expect(file('/etc/haproxy/haproxy.cfg')).to contain('41337 ssl crt /etc/pki/abiquo/monolithic.abiquo.com.crt.haproxy.crt')
  end

  it 'has apache mappings to tomcat configured' do
    %w(api am legal).each do |webapp|
      expect(file('/etc/httpd/sites-available/abiquo.conf')).to contain("<Location /#{webapp}>")
      expect(file('/etc/httpd/sites-available/abiquo.conf')).to contain("ProxyPass ajp://localhost:8010/#{webapp}")
      expect(file('/etc/httpd/sites-available/abiquo.conf')).to contain("ProxyPassReverse ajp://localhost:8010/#{webapp}")
    end
    expect(file('/etc/httpd/sites-available/abiquo.conf')).to contain('ProxyPass http://localhost:8009/m')
  end

  it 'has proxies configured in apache' do
    expect(file('/etc/httpd/sites-available/abiquo.conf')).to contain('ProxyPass http://some_am:8009/am')
  end

  it 'renders Apache directives in config file' do
    expect(file('/etc/httpd/sites-available/abiquo.conf')).to contain('KeepAlive On')
    expect(file('/etc/httpd/sites-available/abiquo.conf')).to contain('MaxKeepAliveRequests 100')
    expect(file('/etc/httpd/sites-available/abiquo.conf')).to contain('KeepAliveTimeout 60')
  end

  it 'has ssl properly configured' do
    expect(file('/etc/httpd/sites-available/abiquo.conf')).to contain('SSLEngine on')
    expect(file('/etc/httpd/sites-available/abiquo.conf')).to contain('SSLProtocol All -SSLv2 -SSLv3')
    expect(file('/etc/httpd/sites-available/abiquo.conf')).to contain('SSLCipherSuite EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH')
    expect(file('/etc/httpd/sites-available/abiquo.conf')).to contain('SSLCertificateFile /etc/pki/abiquo/monolithic.abiquo.com.crt')
    expect(file('/etc/httpd/sites-available/abiquo.conf')).to contain('SSLCertificateKeyFile /etc/pki/abiquo/monolithic.abiquo.com.key')
  end

  it 'has the ui properly configured' do
    expect(file('/var/www/html/ui/config/client-config-custom.json')).to exist
    # The suite is forced to configure the hostname
    expect(file('/var/www/html/ui/config/client-config-custom.json')).to contain('"config.endpoint": "https://monolithic.abiquo.com/api"')
  end

  it 'has tomcat properly configured' do
    expect(file('/opt/abiquo/tomcat/conf/server.xml')).to contain('<Listener className="com.abiquo.listeners.AbiquoConfigurationListener"/>')
    expect(file('/opt/abiquo/tomcat/conf/server.xml')).to be_owned_by('tomcat')
  end

  it 'has the ec2 api tools configured' do
    expect(file('/etc/sysconfig/abiquo/ec2-api-tools')).to contain('^export EC2_HOME=')
  end

  it 'has the abiquo properties file' do
    expect(file('/opt/abiquo/config/abiquo.properties')).to exist
  end

  it 'has the M user properly configured' do
    expect(file('/opt/abiquo/config/abiquo.properties')).to contain('abiquo.m.identity = default_outbound_api_user')
    # Credential is auto generated but at least we want to check it is set
    expect(file('/opt/abiquo/config/abiquo.properties')).to contain('abiquo.m.credential = ')
  end

  it 'has a user in rabbit for Abiquo' do
    expect(command('rabbitmqctl list_users').stdout).to match(/abiquo.*administrator/)
    expect(command('rabbitmqctl list_permissions').stdout).to match(/abiquo\t.*\t.*\t.*/)
  end

  it 'has a redis user with a proper login shell' do
    expect(user('redis')).to exist
    expect(user('redis')).to have_login_shell('/bin/sh')
  end

  it 'has mariadb configured as master' do
    expect(command('mysql -e "show master status"').stdout).to contain('mariadb-bin.000')
  end
end
