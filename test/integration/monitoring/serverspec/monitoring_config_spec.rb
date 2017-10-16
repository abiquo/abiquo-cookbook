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

describe 'Monitoring configuration' do
  include_examples 'common::config'

  it 'kairosdb is configured to use cassandra' do
    expect(file('/opt/kairosdb/conf/kairosdb.properties')).to contain('^kairosdb.jetty.port=8080')
    expect(file('/opt/kairosdb/conf/kairosdb.properties')).to contain('^kairosdb.service.datastore=org.kairosdb.datastore.cassandra.CassandraModule')
    expect(file('/opt/kairosdb/conf/kairosdb.properties')).to contain('^kairosdb.datastore.cassandra.host_list=localhost:9160')
  end

  it 'java 8 is the default one' do
    expect(command('java -version').stderr).to contain('version "1.8')
  end

  it 'has delorean properly configured' do
    expect(file('/etc/abiquo/watchtower/delorean.properties')).to exist
    expect(file('/etc/abiquo/watchtower/delorean-base.conf')).to exist
    expect(file('/etc/abiquo/watchtower/delorean.conf')).to exist
    expect(file('/etc/abiquo/watchtower/delorean.conf')).to contain('delorean {')
    # RabbitMQ configuration
    expect(file('/etc/abiquo/watchtower/delorean.properties')).to contain('abiquo.rabbitmq.username = abiquo')
    expect(file('/etc/abiquo/watchtower/delorean.properties')).to contain('abiquo.rabbitmq.addresses = localhost:5672')
  end

  it 'has emmett properly configured' do
    expect(file('/etc/abiquo/watchtower/emmett.properties')).to exist
    expect(file('/etc/abiquo/watchtower/emmett-base.conf')).to exist
    expect(file('/etc/abiquo/watchtower/emmett.conf')).to exist
    expect(file('/etc/abiquo/watchtower/emmett.conf')).to contain('emmett {')
    # RabbitMQ configuration
    expect(file('/etc/abiquo/watchtower/emmett.properties')).to contain('abiquo.rabbitmq.username = abiquo')
    expect(file('/etc/abiquo/watchtower/emmett.properties')).to contain('abiquo.rabbitmq.addresses = localhost:5672')
  end
end
