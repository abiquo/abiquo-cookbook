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

shared_examples 'server::packages' do
  it 'has the server system packages installed' do
    %w(MariaDB-server MariaDB-client liquibase rabbitmq-server).each do |pkg|
      expect(package(pkg)).to be_installed
    end
  end

  it 'has the server packages installed' do
    expect(package('abiquo-server')).to be_installed
  end
end
