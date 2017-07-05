# Cookbook Name:: abiquo
# Recipe:: install_kairosdb
#
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

package 'kairosdb' do
  action :install
  # We want the service to be stopped immediately after the rpm package starts it, if we are going
  # to replace its config file by a systemd unit. Otherwise we won't be able to properly manage it.
  notifies :stop, 'service[kairosdb]', :immediately if node['platform_version'].to_i == 7
  notifies :disable, 'service[kairosdb]', :immediately if node['platform_version'].to_i == 7
end

service 'kairosdb' do
  action :enable
end

if node['platform_version'].to_i == 7
  # Configure a systemd script if we are in CentOS 7
  file '/etc/init.d/kairosdb' do
    action :delete
  end

  group 'kairosdb' do
    system true
    action :create
  end

  user 'kairosdb' do
    system true
    gid 'kairosdb'
    shell '/bin/false'
    action :create
  end

  directory '/var/run/kairosdb' do
    owner 'kairosdb'
    group 'kairosdb'
    mode '0755'
    action :create
  end

  execute 'chown-kairosdb' do
    command 'chown -R kairosdb:kairosdb /opt/kairosdb'
    action :run
  end

  systemd_unit 'kairosdb.service' do
    content <<-EOU.gsub(/^\s+/, '')
    [Unit]
    Description=KairosDB

    [Service]
    Type=forking
    User=kairosdb
    Environment=KAIROS_PID_FILE=/var/run/kairosdb/kairosdb.pid
    PIDFile=/var/run/kairosdb/kairosdb.pid
    ExecStart=/opt/kairosdb/bin/kairosdb.sh start
    ExecStop=/opt/kairosdb/bin/kairosdb.sh stop

    [Install]
    WantedBy=multi-user.target
    EOU
    action [:create, :enable]
    notifies :restart, 'service[kairosdb]'
  end
end
