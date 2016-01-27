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

    before do
        stub_command('/usr/sbin/httpd -t').and_return(true)
        stub_command("service abiquo-tomcat stop").and_return(true)

        allow(::File).to receive(:executable?).with('/usr/bin/repoquery').and_return(true)
        
        abiquo = double('abiquo')
        installed = double('installed')
        available = double('available')
        
        allow(Mixlib::ShellOut).to receive(:new).with("repoquery --installed 'abiquo-*' --qf '%{name}'", {:environment=>{"LC_ALL"=>"C.UTF-8", "LANGUAGE"=>"C.UTF-8", "LANG"=>"C.UTF-8"}}).and_return(abiquo)
        allow(abiquo).to receive(:run_command).and_return(nil)
        allow(abiquo).to receive(:live_stream).and_return(nil)
        allow(abiquo).to receive(:live_stream=).and_return(nil)
        allow(abiquo).to receive(:error!).and_return(nil)
        allow(abiquo).to receive(:stdout).and_return("abiquo-api\nabiquo-server\n")
        
        allow(Mixlib::ShellOut).to receive(:new).with("repoquery --installed abiquo-api abiquo-server", {:environment=>{"LC_ALL"=>"C.UTF-8", "LANGUAGE"=>"C.UTF-8", "LANG"=>"C.UTF-8"}}).and_return(installed)
        allow(installed).to receive(:run_command).and_return(nil)
        allow(installed).to receive(:live_stream).and_return(nil)
        allow(installed).to receive(:live_stream=).and_return(nil)
        allow(installed).to receive(:error!).and_return(nil)
        allow(installed).to receive(:stdout).and_return("abiquo-api-0:3.6.1-85.el6.noarch\nabiquo-server-0:3.6.1-85.el6.noarch\n")

        allow(Mixlib::ShellOut).to receive(:new).with("repoquery abiquo-api abiquo-server", {:environment=>{"LC_ALL"=>"C.UTF-8", "LANGUAGE"=>"C.UTF-8", "LANG"=>"C.UTF-8"}}).and_return(available)
        allow(available).to receive(:run_command).and_return(nil)
        allow(available).to receive(:live_stream).and_return(nil)
        allow(available).to receive(:live_stream=).and_return(nil)
        allow(available).to receive(:error!).and_return(nil)
        allow(available).to receive(:stdout).and_return("abiquo-api-0:3.6.3-207.el6.noarch\nabiquo-server-0:3.6.3-207.el6.noarch\n")
    end

    it 'does nothing if repoquery is not installed' do
        allow(::File).to receive(:executable?).with('/usr/bin/repoquery').and_return(false)
        
        chef_run.converge('apache2::default',described_recipe)
        resource = chef_run.find_resource(:service, 'abiquo-tomcat')
        expect(resource).to be_nil
        resource = chef_run.find_resource(:service, 'abiquo-aim')
        expect(resource).to be_nil
        resource = chef_run.find_resource(:package, 'abiquo-api')
        expect(resource).to be_nil
    end

    it 'logs a message if there are upgrades' do
        chef_run.converge('apache2::default',described_recipe)
        expect(chef_run).to write_log("Abiquo updates available.")
    end

    it 'logs a message if there are no upgrades' do
        available = double('available')
        allow(Mixlib::ShellOut).to receive(:new).with("repoquery abiquo-api abiquo-server", {:environment=>{"LC_ALL"=>"C.UTF-8", "LANGUAGE"=>"C.UTF-8", "LANG"=>"C.UTF-8"}}).and_return(available)
        allow(available).to receive(:run_command).and_return(nil)
        allow(available).to receive(:live_stream).and_return(nil)
        allow(available).to receive(:live_stream=).and_return(nil)
        allow(available).to receive(:error!).and_return(nil)
        allow(available).to receive(:stdout).and_return("abiquo-api-0:3.6.1-85.el6.noarch\nabiquo-server-0:3.6.1-85.el6.noarch\n")

        chef_run.converge('apache2::default',described_recipe)
        expect(chef_run).to write_log("No Abiquo updates found.")
    end

    it 'does nothing if profile is monitoring' do
        chef_run.node.set['abiquo']['profile'] = 'monitoring'
        chef_run.converge('apache2::default',described_recipe)

        chef_run.converge('apache2::default',described_recipe)
        resource = chef_run.find_resource(:service, 'abiquo-tomcat')
        expect(resource).to be_nil
        resource = chef_run.find_resource(:service, 'abiquo-aim')
        expect(resource).to be_nil
    end

    it 'does nothing if no updates available' do
        available = double('available')
        allow(Mixlib::ShellOut).to receive(:new).with("repoquery abiquo-api abiquo-server", {:environment=>{"LC_ALL"=>"C.UTF-8", "LANGUAGE"=>"C.UTF-8", "LANG"=>"C.UTF-8"}}).and_return(available)
        allow(available).to receive(:run_command).and_return(nil)
        allow(available).to receive(:live_stream).and_return(nil)
        allow(available).to receive(:live_stream=).and_return(nil)
        allow(available).to receive(:error!).and_return(nil)
        allow(available).to receive(:stdout).and_return("abiquo-api-0:3.6.1-85.el6.noarch\nabiquo-server-0:3.6.1-85.el6.noarch\n")

        chef_run.converge('apache2::default',described_recipe)
        resource = chef_run.find_resource(:service, 'abiquo-tomcat')
        expect(resource).to be_nil
        resource = chef_run.find_resource(:service, 'abiquo-aim')
        expect(resource).to be_nil
        resource = chef_run.find_resource(:package, 'abiquo-api')
        expect(resource).to be_nil
    end

    it 'performs upgrade if there are new rpms' do
        chef_run.converge('apache2::default',described_recipe)
        resource = chef_run.find_resource(:service, 'abiquo-tomcat')
        expect(resource).not_to be_nil
        resource = chef_run.find_resource(:service, 'abiquo-aim')
        expect(resource).to be_nil
        resource = chef_run.find_resource(:package, 'abiquo-api')
        expect(resource).not_to be_nil
    end

    it 'stops the monolithic service' do
        chef_run.node.set['abiquo']['profile'] = 'monolithic'
        chef_run.converge('apache2::default',described_recipe)
        expect(chef_run).to stop_service('abiquo-tomcat')
        expect(chef_run).to_not stop_service('abiquo-aim')
    end

    it 'stops the remoteservices service' do
        chef_run.node.set['abiquo']['profile'] = 'remoteservices'
        chef_run.converge('apache2::default',described_recipe)
        
        expect(chef_run).to_not stop_service('abiquo-aim')
    end

    it 'stops the kvm service' do
        chef_run.node.set['abiquo']['profile'] = 'kvm'
        chef_run.converge('apache2::default',described_recipe,'abiquo::service')
        resource = chef_run.find_resource(:service, 'abiquo-tomcat')
        expect(resource).not_to be_nil
        expect(chef_run).to stop_service('abiquo-aim')
    end

    it 'includes the repository recipe' do
        chef_run.converge('apache2::default',described_recipe)
        expect(chef_run).to include_recipe('abiquo::repository')
    end

    it 'upgrades the abiquo packages on monolithic' do
        chef_run.converge('apache2::default',described_recipe)
        %w{abiquo-api abiquo-server}.each do |pkg|
            expect(chef_run).to upgrade_package(pkg)
        end
    end

    it 'upgrades the abiquo packages on server' do
        chef_run.node.set['abiquo']['profile'] = 'server'
        chef_run.converge('apache2::default',described_recipe)
        %w{abiquo-api abiquo-server}.each do |pkg|
            expect(chef_run).to upgrade_package(pkg)
        end
    end

    it 'upgrades the abiquo packages on remoteservices' do
        abiquo = double('abiquo')
        installed = double('installed')
        available = double('available')
        
        allow(Mixlib::ShellOut).to receive(:new).with("repoquery --installed 'abiquo-*' --qf '%{name}'", {:environment=>{"LC_ALL"=>"C.UTF-8", "LANGUAGE"=>"C.UTF-8", "LANG"=>"C.UTF-8"}}).and_return(abiquo)
        allow(abiquo).to receive(:run_command).and_return(nil)
        allow(abiquo).to receive(:live_stream).and_return(nil)
        allow(abiquo).to receive(:live_stream=).and_return(nil)
        allow(abiquo).to receive(:error!).and_return(nil)
        allow(abiquo).to receive(:stdout).and_return("abiquo-virtualfactory\nabiquo-remote-services\n")
        
        allow(Mixlib::ShellOut).to receive(:new).with("repoquery --installed abiquo-virtualfactory abiquo-remote-services", {:environment=>{"LC_ALL"=>"C.UTF-8", "LANGUAGE"=>"C.UTF-8", "LANG"=>"C.UTF-8"}}).and_return(installed)
        allow(installed).to receive(:run_command).and_return(nil)
        allow(installed).to receive(:live_stream).and_return(nil)
        allow(installed).to receive(:live_stream=).and_return(nil)
        allow(installed).to receive(:error!).and_return(nil)
        allow(installed).to receive(:stdout).and_return("abiquo-virtualfactory-0:3.6.1-85.el6.noarch\nabiquo-remote-services-0:3.6.1-85.el6.noarch\n")

        allow(Mixlib::ShellOut).to receive(:new).with("repoquery abiquo-virtualfactory abiquo-remote-services", {:environment=>{"LC_ALL"=>"C.UTF-8", "LANGUAGE"=>"C.UTF-8", "LANG"=>"C.UTF-8"}}).and_return(available)
        allow(available).to receive(:run_command).and_return(nil)
        allow(available).to receive(:live_stream).and_return(nil)
        allow(available).to receive(:live_stream=).and_return(nil)
        allow(available).to receive(:error!).and_return(nil)
        allow(available).to receive(:stdout).and_return("abiquo-virtualfactory-0:3.6.3-207.el6.noarch\nabiquo-remote-services-0:3.6.3-207.el6.noarch\n")

        chef_run.node.set['abiquo']['profile'] = 'remoteservices'
        chef_run.converge('apache2::default',described_recipe)
        %w{abiquo-virtualfactory abiquo-remote-services}.each do |pkg|
            expect(chef_run).to upgrade_package(pkg)
        end
    end

    it 'upgrades the abiquo packages on kvm' do
        abiquo = double('abiquo')
        installed = double('installed')
        available = double('available')
        
        allow(Mixlib::ShellOut).to receive(:new).with("repoquery --installed 'abiquo-*' --qf '%{name}'", {:environment=>{"LC_ALL"=>"C.UTF-8", "LANGUAGE"=>"C.UTF-8", "LANG"=>"C.UTF-8"}}).and_return(abiquo)
        allow(abiquo).to receive(:run_command).and_return(nil)
        allow(abiquo).to receive(:live_stream).and_return(nil)
        allow(abiquo).to receive(:live_stream=).and_return(nil)
        allow(abiquo).to receive(:error!).and_return(nil)
        allow(abiquo).to receive(:stdout).and_return("abiquo-aim\nabiquo-cloud-node\n")
        
        allow(Mixlib::ShellOut).to receive(:new).with("repoquery --installed abiquo-aim abiquo-cloud-node", {:environment=>{"LC_ALL"=>"C.UTF-8", "LANGUAGE"=>"C.UTF-8", "LANG"=>"C.UTF-8"}}).and_return(installed)
        allow(installed).to receive(:run_command).and_return(nil)
        allow(installed).to receive(:live_stream).and_return(nil)
        allow(installed).to receive(:live_stream=).and_return(nil)
        allow(installed).to receive(:error!).and_return(nil)
        allow(installed).to receive(:stdout).and_return("abiquo-aim-0:3.6.1-85.el6.noarch\nabiquo-cloud-node-0:3.6.1-85.el6.noarch\n")

        allow(Mixlib::ShellOut).to receive(:new).with("repoquery abiquo-aim abiquo-cloud-node", {:environment=>{"LC_ALL"=>"C.UTF-8", "LANGUAGE"=>"C.UTF-8", "LANG"=>"C.UTF-8"}}).and_return(available)
        allow(available).to receive(:run_command).and_return(nil)
        allow(available).to receive(:live_stream).and_return(nil)
        allow(available).to receive(:live_stream=).and_return(nil)
        allow(available).to receive(:error!).and_return(nil)
        allow(available).to receive(:stdout).and_return("abiquo-aim-0:3.6.3-207.el6.noarch\nabiquo-cloud-node-0:3.6.3-207.el6.noarch\n")

        chef_run.node.set['abiquo']['profile'] = 'kvm'
        chef_run.converge('apache2::default',described_recipe,'abiquo::service')
        %w{abiquo-aim abiquo-cloud-node}.each do |pkg|
            expect(chef_run).to upgrade_package(pkg)
        end
    end

    it 'does not run liquibase if not configured' do
        chef_run.node.set['abiquo']['db']['upgrade'] = false
        chef_run.node.set['abiquo']['profile'] = 'monolithic'
        chef_run.converge('apache2::default',described_recipe,'abiquo::service')
        expect(chef_run).to_not run_execute('liquibase-update')
    end

    it 'does not run liquibase when kvm' do
        chef_run.node.set['abiquo']['db']['upgrade'] = true
        chef_run.node.set['abiquo']['profile'] = 'kvm'
        chef_run.converge('apache2::default',described_recipe,'abiquo::service')
        expect(chef_run).to_not run_execute('liquibase-update')
    end

    it 'does not run liquibase when remoteservices' do
        chef_run.node.set['abiquo']['db']['upgrade'] = true
        chef_run.node.set['abiquo']['profile'] = 'remoteservices'
        chef_run.converge('apache2::default',described_recipe)
        expect(chef_run).to_not run_execute('liquibase-update')
    end

    it 'runs the liquibase update when monolithic' do
        chef_run.converge('apache2::default',described_recipe)
        resource = chef_run.find_resource(:execute, 'liquibase-update')
        expect(resource).to subscribe_to("package[abiquo-server]").on(:run).immediately
        expect(resource).to do_nothing
        expect(resource).to notify('service[abiquo-tomcat]').to(:restart).delayed
    end

    it 'runs the liquibase update with custom attributes' do
        chef_run.node.set['abiquo']['db']['host'] = '127.0.0.1'
        chef_run.node.set['abiquo']['db']['password'] = 'abiquo'
        chef_run.converge('apache2::default',described_recipe)
        # expect(chef_run).to run_execute('liquibase-update').with(
        #     :cwd => '/usr/share/doc/abiquo-server/database',
        #     :command => 'abiquo-liquibase -h 127.0.0.1 -P 3306 -u root -p abiquo update'
        # )
        resource = chef_run.find_resource(:execute, 'liquibase-update')
        expect(resource).to subscribe_to("package[abiquo-server]").on(:run).immediately
        expect(resource).to do_nothing
        expect(resource).to notify('service[abiquo-tomcat]').to(:restart).delayed
    end

    it 'notifies the monolithic service to restart' do
        chef_run.node.set['abiquo']['profile'] = 'monolithic'
        chef_run.converge('apache2::default',described_recipe)
        resource = chef_run.package('abiquo-server')
        expect(resource).to notify('service[abiquo-tomcat]').to(:start).delayed
    end

    it 'notifies the remoteservices service to restart' do
        chef_run.node.set['abiquo']['profile'] = 'remoteservices'
        chef_run.converge('apache2::default',described_recipe)
        resource = chef_run.package('abiquo-server')
        expect(resource).to notify('service[abiquo-tomcat]').to(:start).delayed
    end

    it 'notifies the kvm service to restart' do
        abiquo = double('abiquo')
        installed = double('installed')
        available = double('available')
        
        allow(Mixlib::ShellOut).to receive(:new).with("repoquery --installed 'abiquo-*' --qf '%{name}'", {:environment=>{"LC_ALL"=>"C.UTF-8", "LANGUAGE"=>"C.UTF-8", "LANG"=>"C.UTF-8"}}).and_return(abiquo)
        allow(abiquo).to receive(:run_command).and_return(nil)
        allow(abiquo).to receive(:live_stream).and_return(nil)
        allow(abiquo).to receive(:live_stream=).and_return(nil)
        allow(abiquo).to receive(:error!).and_return(nil)
        allow(abiquo).to receive(:stdout).and_return("abiquo-aim\nabiquo-cloud-node\n")
        
        allow(Mixlib::ShellOut).to receive(:new).with("repoquery --installed abiquo-aim abiquo-cloud-node", {:environment=>{"LC_ALL"=>"C.UTF-8", "LANGUAGE"=>"C.UTF-8", "LANG"=>"C.UTF-8"}}).and_return(installed)
        allow(installed).to receive(:run_command).and_return(nil)
        allow(installed).to receive(:live_stream).and_return(nil)
        allow(installed).to receive(:live_stream=).and_return(nil)
        allow(installed).to receive(:error!).and_return(nil)
        allow(installed).to receive(:stdout).and_return("abiquo-aim-0:3.6.1-85.el6.noarch\nabiquo-cloud-node-0:3.6.1-85.el6.noarch\n")

        allow(Mixlib::ShellOut).to receive(:new).with("repoquery abiquo-aim abiquo-cloud-node", {:environment=>{"LC_ALL"=>"C.UTF-8", "LANGUAGE"=>"C.UTF-8", "LANG"=>"C.UTF-8"}}).and_return(available)
        allow(available).to receive(:run_command).and_return(nil)
        allow(available).to receive(:live_stream).and_return(nil)
        allow(available).to receive(:live_stream=).and_return(nil)
        allow(available).to receive(:error!).and_return(nil)
        allow(available).to receive(:stdout).and_return("abiquo-aim-0:3.6.3-207.el6.noarch\nabiquo-cloud-node-0:3.6.3-207.el6.noarch\n")

        chef_run.node.set['abiquo']['profile'] = 'kvm'
        chef_run.converge('apache2::default',described_recipe,'abiquo::service')
        resource = chef_run.package('abiquo-aim')
        expect(resource).to notify('service[abiquo-aim]').to(:start).delayed
    end

    %w(monolithic remoteservices kvm).each do |profile|
        it "includes the #{profile} setup recipe" do
            chef_run.node.set['abiquo']['profile'] = profile
            chef_run.converge('apache2::default',described_recipe,'abiquo::service')
            expect(chef_run).to include_recipe("abiquo::setup_#{profile}")
        end
    end
end
