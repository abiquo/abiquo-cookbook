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
  include_examples 'common::config'
  include_examples 'common::redis'
  include_examples 'abiquo::config'
  include_examples 'frontend::config'
  include_examples 'server::config'
  include_examples 'v2v::config'

  it 'has rabbit configured with ssl' do
    expect(file('/opt/abiquo/config/abiquo.properties')).to contain('abiquo.rabbitmq.tls = true')
    expect(file('/opt/abiquo/config/abiquo.properties')).to contain('abiquo.rabbitmq.addresses = localhost:5671')
  end

  it 'has the rabbit ssl certificates installed' do
    expect(file('/etc/rabbitmq/frontend.bcn.abiquo.com.crt')).to be_owned_by('rabbitmq')
    expect(file('/etc/rabbitmq/frontend.bcn.abiquo.com.key')).to be_owned_by('rabbitmq')
  end

  it 'has mariadb configured as master' do
    expect(command('mysql -e "show master status"').stdout).to contain('mariadb-bin.000')
  end

  it 'has mariadb binlog_format as ROW' do
    expect(command('mysql -e "select @@binlog_format"').stdout).to contain('ROW')
  end

  it 'has DB properly configured' do
    expect(file('/opt/abiquo/tomcat/conf/Catalina/localhost/api.xml')).to contain('username="root" password=""')
    expect(file('/opt/abiquo/tomcat/conf/Catalina/localhost/m.xml')).to contain('username="root" password=""')
  end

  it 'has the sudoers file for the nfs plugin' do
    expect(file('/etc/sudoers.d/abiquo-tomcat-nfs')).to contain('tomcat ALL=(ALL) NOPASSWD: /usr/bin/nfs-plugin')
  end

  it 'has the sudoers file for the appliance manager' do
    expect(file('/etc/sudoers.d/abiquo-tomcat-repo')).to contain('tomcat ALL=(ALL) NOPASSWD: /bin/chown tomcat *')
  end
end
