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

describe 'Server packages' do
  it 'has the system packages installed' do
    %w(MariaDB-server MariaDB-client redis liquibase rabbitmq-server jdk cronie).each do |pkg|
      expect(package(pkg)).to be_installed
    end
  end

  it 'has the abiquo packages installed' do
    %w(server sosreport-plugins tutorials websockify).each do |pkg|
      expect(package("abiquo-#{pkg}")).to be_installed
    end
  end

  it 'does not have other abiquo installed' do
    %w(remote-services monolithic nodecollector).each do |pkg|
      expect(package("abiquo-#{pkg}")).to_not be_installed
    end
  end

  it 'has the haproxy package installed' do
    expect(package('haproxy')).to be_installed
  end

  it 'has the strong jce encryption policies installed' do
    expect(file('/usr/java/default/jre/lib/security/local_policy.jar').md5sum).to eq('dabfcb23d7bf9bf5a201c3f6ea9bfb2c')
    expect(file('/usr/java/default/jre/lib/security/US_export_policy.jar').md5sum).to eq('ef6e8eae7d1876d7f05d765d2c2e0529')
  end
end
