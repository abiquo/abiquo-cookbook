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

shared_examples 'server::config' do
  it 'has the M user properly configured' do
    expect(file('/opt/abiquo/config/abiquo.properties')).to contain('abiquo.m.identity = default_outbound_api_user')
    # Credential is auto generated but at least we want to check it is set
    expect(file('/opt/abiquo/config/abiquo.properties')).to contain('abiquo.m.credential = ')
    expect(file('/opt/abiquo/config/abiquo.properties')).to contain("abiquo.m.instanceid = #{host_inventory[:hostname]}")
  end

  it 'has a user in rabbit for Abiquo' do
    expect(command('rabbitmqctl list_users').stdout).to match(/abiquo.*administrator/)
    expect(command('rabbitmqctl list_permissions').stdout).to match(/abiquo\t.*\t.*\t.*/)
  end

  it 'has the Abiquo rabbit properties' do
    expect(file('/opt/abiquo/config/abiquo.properties')).to contain('abiquo.rabbitmq.username = abiquo')
    expect(file('/opt/abiquo/config/abiquo.properties')).to contain('abiquo.rabbitmq.password = abiquo')
    expect(file('/opt/abiquo/config/abiquo.properties')).to contain('abiquo.rabbitmq.addresses = 127.0.0.1:5672')
  end

  it 'has apache mappings to tomcat configured' do
    %w(api legal).each do |webapp|
      expect(file('/etc/httpd/sites-available/abiquo.conf')).to contain("<Location /#{webapp}>")
      expect(file('/etc/httpd/sites-available/abiquo.conf')).to contain("ProxyPass ajp://localhost:8010/#{webapp}")
      expect(file('/etc/httpd/sites-available/abiquo.conf')).to contain("ProxyPassReverse ajp://localhost:8010/#{webapp}")
    end

    expect(file('/etc/httpd/sites-available/abiquo.conf')).to contain('<Location /m>')
    expect(file('/etc/httpd/sites-available/abiquo.conf')).to contain('ProxyPass http://localhost:8009/m')
    expect(file('/etc/httpd/sites-available/abiquo.conf')).to contain('<Location /am2>')
    expect(file('/etc/httpd/sites-available/abiquo.conf')).to contain('ProxyPass http://some_am:8009/am')
    expect(file('/etc/httpd/sites-available/abiquo.conf')).to contain('Header add "Access-Control-Allow-Origin" "*"')
  end
end
