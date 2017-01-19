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

describe 'abiquo::repository' do
  let(:chef_run) { ChefSpec::SoloRunner.new }

  it 'cleans the yum cache' do
    chef_run.converge(described_recipe)
    resource = chef_run.execute('clean-yum-cache')
    expect(resource).to do_nothing
    expect(resource.command).to eq('yum clean all')
  end

  it 'deletes the yum cache directory' do
    chef_run.converge(described_recipe)
    resource = chef_run.directory('/var/cache/yum')
    expect(resource).to do_nothing
    expect(resource.ignore_failure).to eq(true)
    expect(resource.recursive).to eq(true)
  end

  it 'includes the yum-epel recipe' do
    chef_run.converge(described_recipe)
    expect(chef_run).to include_recipe('yum-epel')
  end

  it 'does not include the yum-epel recipe if not install-repo' do
    chef_run.node.set['abiquo']['yum']['install-repo'] = false
    chef_run.converge(described_recipe)
    expect(chef_run).to_not include_recipe('yum-epel')
  end

  it 'creates the base repository' do
    chef_run.converge(described_recipe)
    expect(chef_run).to create_yum_repository('abiquo-base').with(
      description: 'Abiquo base repository',
      baseurl: 'http://mirror.abiquo.com/el$releasever/3.10/os/x86_64',
      gpgcheck: true,
      gpgkey: 'file:///etc/pki/rpm-gpg/RPM-GPG-RSA-KEY-Abiquo'
    )

    resource = chef_run.find_resource(:yum_repository, 'abiquo-base')
    expect(resource).to subscribe_to('package[abiquo-release-ee]').on(:create)
    expect(resource).to notify('directory[/var/cache/yum]').to(:delete).immediately
    expect(resource).to notify('execute[clean-yum-cache]').to(:run).immediately
  end

  it 'does not create the base repository if not install-repo' do
    chef_run.node.set['abiquo']['yum']['install-repo'] = false
    chef_run.converge(described_recipe)
    expect(chef_run).to_not create_yum_repository('abiquo-base')
  end

  it 'creates the updates repository' do
    chef_run.converge(described_recipe)
    expect(chef_run).to create_yum_repository('abiquo-updates').with(
      description: 'Abiquo updates repository',
      baseurl: 'http://mirror.abiquo.com/el$releasever/3.10/updates/x86_64',
      gpgcheck: true,
      gpgkey: 'file:///etc/pki/rpm-gpg/RPM-GPG-RSA-KEY-Abiquo'
    )

    resource = chef_run.find_resource(:yum_repository, 'abiquo-updates')
    expect(resource).to subscribe_to('package[abiquo-release-ee]')
    expect(resource).to notify('directory[/var/cache/yum]').to(:delete).immediately
    expect(resource).to notify('execute[clean-yum-cache]').to(:run).immediately
  end

  it 'does not create the updates repository if not install-repo' do
    chef_run.node.set['abiquo']['yum']['install-repo'] = false
    chef_run.converge(described_recipe)
    expect(chef_run).to_not create_yum_repository('abiquo-updates')
  end

  it 'installs the abiquo-release-ee package' do
    chef_run.converge(described_recipe)
    expect(chef_run).to install_package('abiquo-release-ee').with(
      options: '--nogpgcheck'
    )
  end

  it 'does not install the abiquo-release-ee package if not install-repo' do
    chef_run.node.set['abiquo']['yum']['install-repo'] = false
    chef_run.converge(described_recipe)
    expect(chef_run).to_not install_package('abiquo-release-ee')
  end

  it 'installs yum-utils package' do
    chef_run.converge(described_recipe)
    expect(chef_run).to install_package('yum-utils')
  end
end
