# Cookbook Name:: abiquo
# Recipe:: upgrade
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

Chef::Recipe.send(:include, Abiquo::Platform)

svc = node['abiquo']['profile'] == 'kvm' ? 'abiquo-aim' : 'abiquo-tomcat'
service svc do
    action :stop
end

include_recipe "abiquo::repository"

# Wildcards can't be used with the regular resource package, so just run the command
execute "yum-upgrade-abiquo" do
    command 'yum -y upgrade abiquo-*'
end

liquibase_cmd = "java -cp /usr/share/java/liquibase.jar liquibase.integration.commandline.Main " \
    "--changeLogFile=/usr/share/doc/abiquo-server/database/src/kinton_master_changelog.xml " \
    "--url=\"jdbc:mysql://#{node['abiquo']['db']['host']}:#{node['abiquo']['db']['port']}/kinton\"  " \
    "--driver=com.mysql.jdbc.Driver " \
    "--classpath=/opt/abiquo/tomcat/lib/mysql-connector-java-5.1.27-bin.jar " \
    "--username #{node['abiquo']['db']['user']} "
liquibase_cmd += "--password #{node['abiquo']['db']['password']} " unless node['abiquo']['db']['password'].nil?
liquibase_cmd += "update"

execute "liquibase-update" do
    command liquibase_cmd
    cwd '/usr/share/doc/abiquo-server/database'
    only_if { node['abiquo']['profile'] == 'monolithic' && node['abiquo']['db']['upgrade'] }
end

include_recipe "abiquo::setup_#{node['abiquo']['profile']}"
