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

describe 'abiquo::upgrade' do
    let(:chef_run) { ChefSpec::SoloRunner.new }

    it 'stops the monolithic service' do
        chef_run.node.set['abiquo']['profile'] = 'monolithic'
        chef_run.converge(described_recipe)
        expect(chef_run).to stop_service('abiquo-tomcat')
        expect(chef_run).to_not stop_service('abiquo-aim')
    end

    it 'stops the remoteservices service' do
        chef_run.node.set['abiquo']['profile'] = 'remoteservices'
        chef_run.converge(described_recipe)
        expect(chef_run).to stop_service('abiquo-tomcat')
        expect(chef_run).to_not stop_service('abiquo-aim')
    end

    it 'stops the kvm service' do
        chef_run.node.set['abiquo']['profile'] = 'kvm'
        chef_run.converge(described_recipe)
        expect(chef_run).to_not stop_service('abiquo-tomcat')
        expect(chef_run).to stop_service('abiquo-aim')
    end

    it 'includes the repository recipe' do
        chef_run.converge(described_recipe)
        expect(chef_run).to include_recipe('abiquo::repository')
    end

    it 'upgrades the abiquo packages' do
        chef_run.converge(described_recipe)
        expect(chef_run).to run_execute('yum-upgrade-abiquo').with(
            :command => 'yum -y upgrade abiquo-*'
        )
    end

    it 'does not run liquibase if not configured' do
        chef_run.node.set['abiquo']['db']['upgrade'] = false
        chef_run.node.set['abiquo']['profile'] = 'monolithic'
        chef_run.converge(described_recipe)
        expect(chef_run).to_not run_execute('liquibase-update')
    end

    it 'does not run liquibase when kvm' do
        chef_run.node.set['abiquo']['db']['upgrade'] = true
        chef_run.node.set['abiquo']['profile'] = 'kvm'
        chef_run.converge(described_recipe)
        expect(chef_run).to_not run_execute('liquibase-update')
    end

    it 'does not run liquibase when remoteservices' do
        chef_run.node.set['abiquo']['db']['upgrade'] = true
        chef_run.node.set['abiquo']['profile'] = 'remoteservices'
        chef_run.converge(described_recipe)
        expect(chef_run).to_not run_execute('liquibase-update')
    end

    it 'runs the liquibase update when monolithic' do
        chef_run.converge(described_recipe)
        expect(chef_run).to run_execute('liquibase-update').with(
            :cwd => '/usr/share/doc/abiquo-server/database',
            :command => 'java -cp /usr/share/java/liquibase.jar liquibase.integration.commandline.Main ' \
                        '--changeLogFile=/usr/share/doc/abiquo-server/database/src/kinton_master_changelog.xml ' \
                        '--url="jdbc:mysql://localhost:3306/kinton"  ' \
                        '--driver=com.mysql.jdbc.Driver ' \
                        '--classpath=/opt/abiquo/tomcat/lib/mysql-connector-java-5.1.27-bin.jar ' \
                        '--username root update'
        )
    end

    it 'runs the liquibase update with custom attributes' do
        chef_run.node.set['abiquo']['db']['host'] = '127.0.0.1'
        chef_run.node.set['abiquo']['db']['password'] = 'abiquo'
        chef_run.converge(described_recipe)
        expect(chef_run).to run_execute('liquibase-update').with(
            :cwd => '/usr/share/doc/abiquo-server/database',
            :command => 'java -cp /usr/share/java/liquibase.jar liquibase.integration.commandline.Main ' \
                        '--changeLogFile=/usr/share/doc/abiquo-server/database/src/kinton_master_changelog.xml ' \
                        '--url="jdbc:mysql://127.0.0.1:3306/kinton"  ' \
                        '--driver=com.mysql.jdbc.Driver ' \
                        '--classpath=/opt/abiquo/tomcat/lib/mysql-connector-java-5.1.27-bin.jar ' \
                        '--username root --password abiquo update'
        )
    end

    %w(monolithic remoteservices kvm).each do |profile|
        it "includes the #{profile} setup recipe" do
            chef_run.node.set['abiquo']['profile'] = profile
            chef_run.converge(described_recipe)
            expect(chef_run).to include_recipe("abiquo::setup_#{profile}")
        end
    end
end
