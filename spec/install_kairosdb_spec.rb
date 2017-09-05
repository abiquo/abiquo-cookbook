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

require 'spec_helper'

shared_examples 'monitoring' do
  it 'enables the kairosdb service' do
    expect(chef_run).to enable_service('kairosdb')
  end

  it 'installs the kairosdb package' do
    expect(chef_run).to install_package('kairosdb')
  end
end

describe 'abiquo::install_kairosdb' do
  context 'when CentOS 7' do
    cached(:chef_run) { ChefSpec::SoloRunner.new.converge(described_recipe) }

    include_examples 'monitoring'

    it 'stops and disables the service' do
      resource = chef_run.package('kairosdb')
      expect(resource).to notify('service[kairosdb]').to(:stop).immediately
      expect(resource).to notify('service[kairosdb]').to(:disable).immediately
    end

    it 'configures the kairos user' do
      expect(chef_run).to create_user('kairosdb').with(
        system: true,
        gid: 'kairosdb',
        shell: '/bin/false'
      )
    end

    it 'configures the kairos group' do
      expect(chef_run).to create_group('kairosdb').with(system: true)
    end

    it 'configures the kairos permissions' do
      expect(chef_run).to create_directory('/opt/kairosdb/run').with(
        owner: 'kairosdb',
        group: 'kairosdb',
        mode: '0755'
      )
      expect(chef_run).to run_execute('chown-kairosdb').with(
        command: 'chown -R kairosdb:kairosdb /opt/kairosdb'
      )
      expect(chef_run).to run_execute('chown-kairosdb-cache').with(
        command: 'chown -R kairosdb:kairosdb /tmp/kairos_cache'
      )
    end

    it 'installs the systemd service unit' do
      expect(chef_run).to delete_file('/etc/init.d/kairosdb')
      expect(chef_run).to create_systemd_unit('kairosdb.service')
      expect(chef_run).to create_systemd_unit('kairosdb.service')
      resource = chef_run.systemd_unit('kairosdb.service')
      expect(resource).to notify('service[kairosdb]').to(:restart).delayed
    end
  end

  context 'when CentOS 6' do
    cached(:chef_run) { ChefSpec::SoloRunner.new(platform: 'centos', version: '6.5').converge(described_recipe) }

    include_examples 'monitoring'

    it 'does not stop the kairos service after installing' do
      resource = chef_run.package('kairosdb')
      expect(resource).to_not notify('service[kairosdb]').to(:stop)
      expect(resource).to_not notify('service[kairosdb]').to(:disable)
    end

    it 'does not configure the kairos user and permissions' do
      expect(chef_run).to_not create_user('kairosdb')
      expect(chef_run).to_not create_group('kairosdb')
      expect(chef_run).to_not create_directory('/opt/kairosdb/run')
      expect(chef_run).to_not run_execute('chown-kairosdb')
      expect(chef_run).to_not run_execute('chown-kairosdb-cache')
    end

    it 'does not install the systemd service unit' do
      expect(chef_run).to_not delete_file('/etc/init.d/kairosdb')
      expect(chef_run).to_not create_systemd_unit('kairosdb.service')
      expect(chef_run).to_not enable_systemd_unit('kairosdb.service')
    end
  end
end
