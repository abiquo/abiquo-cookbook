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

describe 'Monitoring packages' do
  it 'has the jdk package installed' do
    expect(package('jdk')).to be_installed
  end

  it 'has the mariadb client package installed' do
    expect(package('MariaDB-client')).to be_installed
  end

  it 'has the kairosdb package installed' do
    expect(package('kairosdb')).to be_installed
  end

  it 'has the delorean package installed' do
    expect(package('abiquo-delorean')).to be_installed
  end

  it 'has the emmett package installed' do
    expect(package('abiquo-emmett')).to be_installed
  end
end
