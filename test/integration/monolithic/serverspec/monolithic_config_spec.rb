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
  include_examples 'websockify::config'

  it 'has mariadb configured as master' do
    expect(command('mysql -e "show master status"').stdout).to contain('mariadb-bin.000')
  end

  it 'has DB properly configured' do
    expect(file('/opt/abiquo/tomcat/conf/Catalina/localhost/api.xml')).to contain('username="root" password=""')
    expect(file('/opt/abiquo/tomcat/conf/Catalina/localhost/m.xml')).to contain('username="root" password=""')
  end

  it 'has the default backend bound to the first one' do
    expect(file('/etc/haproxy/haproxy.cfg')).to contain('default_backend ws')
    expect(file('/etc/haproxy/haproxy.cfg')).to contain('server websockify0 10.10.10.10:41338 weight 1 maxconn 1024 check')
  end

  it 'has the sudoers file for the nfs plugin' do
    expect(file('/etc/sudoers.d/abiquo-tomcat-nfs')).to contain('tomcat ALL=(ALL) NOPASSWD: /usr/bin/nfs-plugin')
  end
end
