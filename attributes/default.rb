# Cookbook Name:: abiquo
# Attributes:: abiquo
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

# The profile to install: monolithic, remoteservices or kvm
default['abiquo']['profile'] = 'monolithic'

# Wether or not to install external dependant services
# like MariaDB, Redis, RabbitMQ
# Set to false if you wish to use existing servers.
default['abiquo']['install_ext_services'] = true

# Common properties
default['abiquo']['license'] = nil

# NFS repository configuration
default['abiquo']['nfs']['mountpoint'] = '/opt/vm_repository'
default['abiquo']['nfs']['location'] = nil # Change to something like: "127.0.0.1:/opt/vm_repository"

# Yum repository configuration
default['abiquo']['yum']['install-repo'] = true
default['abiquo']['yum']['base-repo'] = 'http://mirror.abiquo.com/el$releasever/4.7/os/x86_64'
default['abiquo']['yum']['updates-repo'] = 'http://mirror.abiquo.com/el$releasever/4.7/updates/x86_64'
default['abiquo']['yum']['gpg-check'] = true
default['abiquo']['yum']['proxy'] = nil

# Database configuration
default['abiquo']['db']['host'] = 'localhost'
default['abiquo']['db']['port'] = 3306
default['abiquo']['db']['user'] = 'root'
default['abiquo']['db']['from'] = 'localhost'
default['abiquo']['db']['password'] = nil
default['abiquo']['db']['upgrade'] = true
default['abiquo']['db']['enable-master'] = false

# Redis configuration
default['redisio']['servers'] = [{
  'name' => 'master',
  'port' => 6379,
  'address' => '0.0.0.0',
}]
default['redisio']['package_install'] = true
default['redisio']['version'] = nil
default['redisio']['package_name'] = 'redis'
default['redisio']['bin_path'] = '/usr/bin'

# RabbitMQ configuration
default['rabbitmq']['config'] = '/etc/rabbitmq/rabbitmq.config'
default['rabbitmq']['use_distro_version'] = true
default['rabbitmq']['ssl'] = false
default['rabbitmq']['port'] = 5672
default['rabbitmq']['ssl_port'] = 5671
default['rabbitmq']['nodename'] = "rabbit@#{node['hostname']}"
default['rabbitmq']['config-env_template_cookbook'] = 'abiquo'
default['abiquo']['rabbitmq']['username'] = 'abiquo'
default['abiquo']['rabbitmq']['password'] = 'abiquo'
default['abiquo']['rabbitmq']['addresses'] = "localhost:#{node['rabbitmq'][node['rabbitmq']['ssl'] ? 'ssl_port' : 'port']}"
default['abiquo']['rabbitmq']['tags'] = 'administrator'
default['abiquo']['rabbitmq']['vhost'] = '/'
default['abiquo']['rabbitmq']['tls'] = node['rabbitmq']['ssl']
default['abiquo']['rabbitmq']['tlstrustall'] = false
default['abiquo']['rabbitmq']['generate_cert'] = false

# Tomcat configuration
default['abiquo']['tomcat']['http-port'] = 8009
default['abiquo']['tomcat']['ajp-port'] = 8010
default['abiquo']['tomcat']['wait-for-webapps'] = false
default['abiquo']['tomcat']['alias'] = node['fqdn']

# Override the Apache proxy configuration
default['apache']['proxy']['order'] = 'allow,deny'
default['apache']['proxy']['deny_from']  = 'none'
default['apache']['proxy']['allow_from'] = 'all'
default['apache']['listen_ports'] = [80, 443]

# Determine if the server should include the frontend components
default['abiquo']['server']['install_frontend'] = true

# UI Apache configuration
default['abiquo']['ui_apache_opts'] = {}

# UI app configuration attributes. These attributes will be rendered
# in /var/www/html/ui/config/client-config-custom.json
default['abiquo']['ui_config'] = { 'config.endpoint' => "https://#{node['fqdn']}/api" }
default['abiquo']['ui_proxies'] = {}

# Wheter or not to generate a self signed certificate
# for this host. If not, provide path to certificate,
# private key and optionally a CA cert. The cookbook
# does not manage the certificate files path provided
# for non generated certificates.
default['abiquo']['certificate']['common_name'] = node['fqdn']
default['abiquo']['certificate']['organization'] = 'Abiquo'
default['abiquo']['certificate']['department'] = 'Engineering'
default['abiquo']['certificate']['country'] = 'ES'
default['abiquo']['certificate']['source'] = 'self-signed'
default['abiquo']['certificate']['file'] = "/etc/pki/abiquo/#{node['abiquo']['certificate']['common_name']}.crt"
default['abiquo']['certificate']['key_file'] = "/etc/pki/abiquo/#{node['abiquo']['certificate']['common_name']}.key"
default['abiquo']['certificate']['ca_file'] = nil

# Additional certs to add to Java truststore
# Provide a hash of {alias => url} or {alias => host}
# { 'api' => 'https://somehost/' }
# or just
# { 'someservice' => 'someservice.local' }
default['abiquo']['certificate']['additional_certs'] = {}

# Configure abiquo KVM
default['abiquo']['aim']['port'] = 8889
default['abiquo']['aim']['include_neutron'] = false
default['abiquo']['aim']['neutron']['vlan_ranges'] = 'abq-vlans:2:4094'
default['abiquo']['aim']['neutron']['interface_mappings'] = 'external:ens3,abq-vlans:ens4'
default['abiquo']['aim']['neutron']['rabbit_userid'] = 'abiquo'
default['abiquo']['aim']['neutron']['rabbit_password'] = 'xabiquo'
default['abiquo']['aim']['neutron']['rabbit_host'] = 'localhost'
default['abiquo']['aim']['neutron']['rabbit_port'] = 5672
default['abiquo']['aim']['neutron']['identity_uri'] = 'http://localhost:35357/v3'
default['abiquo']['aim']['neutron']['domain'] = 'default'
default['abiquo']['aim']['neutron']['project'] = 'service'
default['abiquo']['aim']['neutron']['admin_user'] = 'admin'
default['abiquo']['aim']['neutron']['admin_password'] = 'xabiquo'

# Configure monitoring node
default['abiquo']['monitoring']['cassandra']['cluster_name'] = 'abiquo'
default['abiquo']['monitoring']['kairosdb']['host'] = 'localhost'
default['abiquo']['monitoring']['kairosdb']['port'] = 8080
default['abiquo']['monitoring']['db']['host'] = 'localhost'
default['abiquo']['monitoring']['db']['port'] = 3306
default['abiquo']['monitoring']['db']['user'] = 'root'
default['abiquo']['monitoring']['db']['password'] = nil
default['abiquo']['monitoring']['db']['from'] = 'localhost'
default['abiquo']['monitoring']['db']['install'] = true
default['abiquo']['monitoring']['emmett']['port'] = 36638
default['abiquo']['monitoring']['emmett']['ssl'] = false

# Override the default java configuration
default['java']['oracle']['accept_oracle_download_terms'] = true
default['java']['install_flavor'] = 'oracle_rpm'
default['java']['oracle_rpm']['type'] = 'jdk'
default['java']['java_home'] = '/usr/java/default'
default['java']['jdk_version'] = 8

# Override Cassandra default configuration to make sure it is always running properly
default['cassandra']['notify_restart'] = true
default['cassandra']['use_systemd'] = true if node['platform_version'].to_i >= 7

# Default properties
default['abiquo']['properties']['abiquo.datacenter.id'] = node['hostname']
default['abiquo']['properties']['abiquo.rabbitmq.username'] = node['abiquo']['rabbitmq']['username']
default['abiquo']['properties']['abiquo.rabbitmq.password'] = node['abiquo']['rabbitmq']['password']
default['abiquo']['properties']['abiquo.rabbitmq.addresses'] = node['abiquo']['rabbitmq']['addresses']
default['abiquo']['properties']['abiquo.rabbitmq.tls'] = node['abiquo']['rabbitmq']['tls']
default['abiquo']['properties']['abiquo.rabbitmq.tls.trustallcertificates'] = node['abiquo']['rabbitmq']['tlstrustall']
default['abiquo']['properties']['abiquo.vncport.min'] = 5900
default['abiquo']['properties']['abiquo.vncport.max'] = 5999

case node['abiquo']['profile']
when 'monolithic', 'server'
  default['abiquo']['properties']['abiquo.m.instanceid'] = node['hostname']
  default['abiquo']['properties']['abiquo.m.identity'] = 'default_outbound_api_user'
  default['abiquo']['properties']['abiquo.server.sessionTimeout'] = 30
  default['abiquo']['properties']['abiquo.server.mail.server'] = '127.0.0.1'
  default['abiquo']['properties']['abiquo.server.mail.user'] = 'none@none.es'
  default['abiquo']['properties']['abiquo.server.mail.password'] = 'none'
  default['abiquo']['properties']['abiquo.redis.host'] = '127.0.0.1'
  default['abiquo']['properties']['abiquo.redis.port'] = 6379
  default['abiquo']['properties']['abiquo.monitoring.enabled'] = false
  default['abiquo']['properties']['abiquo.server.api.location'] = "https://#{node['fqdn']}/api"
when 'remoteservices'
  default['abiquo']['properties']['abiquo.appliancemanager.localRepositoryPath'] = node['abiquo']['nfs']['mountpoint']
  default['abiquo']['properties']['abiquo.appliancemanager.checkMountedRepository'] = !node['abiquo']['nfs']['location'].nil?
  default['abiquo']['properties']['abiquo.monitoring.enabled'] = false
end

# KairosDB config
default['abiquo']['kairosdb_config']['kairosdb.telnetserver.port'] = 4242
default['abiquo']['kairosdb_config']['kairosdb.service.telnet'] = 'org.kairosdb.core.telnet.TelnetServerModule'
default['abiquo']['kairosdb_config']['kairosdb.service.http'] = 'org.kairosdb.core.http.WebServletModule'
default['abiquo']['kairosdb_config']['kairosdb.service.reporter'] = 'org.kairosdb.core.reporting.MetricReportingModule'
default['abiquo']['kairosdb_config']['kairosdb.datapoints.factory.long'] = 'org.kairosdb.core.datapoints.LongDataPointFactoryImpl'
default['abiquo']['kairosdb_config']['kairosdb.datapoints.factory.double'] = 'org.kairosdb.core.datapoints.DoubleDataPointFactoryImpl'
default['abiquo']['kairosdb_config']['kairosdb.datapoints.factory.string'] = 'org.kairosdb.core.datapoints.StringDataPointFactory'
default['abiquo']['kairosdb_config']['kairosdb.reporter.schedule'] = '0 */1 * * * ?'
default['abiquo']['kairosdb_config']['kairosdb.jetty.port'] = node['abiquo']['monitoring']['kairosdb']['port']
default['abiquo']['kairosdb_config']['kairosdb.jetty.static_web_root'] = 'webroot'
default['abiquo']['kairosdb_config']['kairosdb.datastore.concurrentQueryThreads'] = 5
default['abiquo']['kairosdb_config']['kairosdb.service.datastore'] = 'org.kairosdb.datastore.cassandra.CassandraModule'
default['abiquo']['kairosdb_config']['kairosdb.datastore.h2.database_path'] = 'build/h2db'
default['abiquo']['kairosdb_config']['kairosdb.datastore.cassandra.host_list'] = "localhost:#{node['cassandra']['config']['rpc_port']}"
default['abiquo']['kairosdb_config']['kairosdb.datastore.cassandra.keyspace'] = 'kairosdb'
default['abiquo']['kairosdb_config']['kairosdb.datastore.cassandra.replication_factor'] = 1
default['abiquo']['kairosdb_config']['kairosdb.datastore.cassandra.write_delay'] = 1000
default['abiquo']['kairosdb_config']['kairosdb.datastore.cassandra.write_buffer_max_size'] = 500000
default['abiquo']['kairosdb_config']['kairosdb.datastore.cassandra.single_row_read_size'] = 10240
default['abiquo']['kairosdb_config']['kairosdb.datastore.cassandra.multi_row_size'] = 1000
default['abiquo']['kairosdb_config']['kairosdb.datastore.cassandra.multi_row_read_size'] = 1024
default['abiquo']['kairosdb_config']['kairosdb.datastore.cassandra.row_key_cache_size'] = 10240
default['abiquo']['kairosdb_config']['kairosdb.datastore.cassandra.string_cache_size'] = 5000
default['abiquo']['kairosdb_config']['kairosdb.datastore.cassandra.increase_buffer_size_schedule'] = '0 */5 * * * ?'
default['abiquo']['kairosdb_config']['kairosdb.datastore.cassandra.read_consistency_level'] = 'ONE'
default['abiquo']['kairosdb_config']['kairosdb.datastore.cassandra.write_consistency_level'] = 'QUORUM'
default['abiquo']['kairosdb_config']['kairosdb.datastore.cassandra.datapoint_ttl'] = 31536000
default['abiquo']['kairosdb_config']['kairosdb.datastore.hbase.timeseries_table'] = 'tsdb'
default['abiquo']['kairosdb_config']['kairosdb.datastore.hbase.uinqueids_table'] = 'tsdb-uid'
default['abiquo']['kairosdb_config']['kairosdb.datastore.hbase.zoo_keeper_quorum'] = 'localhost'
default['abiquo']['kairosdb_config']['kairosdb.datastore.hbase.zoo_keeper_base_dir'] = ''
default['abiquo']['kairosdb_config']['kairosdb.datastore.hbase.auto_create_metrics'] = true
default['abiquo']['kairosdb_config']['kairosdb.datastore.remote.data_dir'] = '.'
default['abiquo']['kairosdb_config']['kairosdb.datastore.remote.remote_url'] = ''
default['abiquo']['kairosdb_config']['kairosdb.datastore.remote.schedule'] = '0 */30 * * * ?'
default['abiquo']['kairosdb_config']['kairosdb.datastore.remote.random_delay'] = 0
default['abiquo']['kairosdb_config']['kairosdb.query_cache.cache_file_cleaner_schedule'] = '0 0 12 ? * SUN *'
