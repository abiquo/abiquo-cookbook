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
default['abiquo']['yum']['base-repo'] = 'http://mirror.abiquo.com/el$releasever/3.10/os/x86_64'
default['abiquo']['yum']['updates-repo'] = 'http://mirror.abiquo.com/el$releasever/3.10/updates/x86_64'
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
  'address' => '0.0.0.0'
}]
default['redisio']['package_install'] = true
default['redisio']['version'] = nil
default['redisio']['package_name'] = 'redis'
default['redisio']['bin_path'] = '/usr/bin'

# RabbitMQ configuration
default['abiquo']['rabbitmq']['username'] = 'abiquo'
default['abiquo']['rabbitmq']['password'] = 'abiquo'
default['abiquo']['rabbitmq']['tags'] = 'administrator'
default['abiquo']['rabbitmq']['vhost'] = '/'
default['rabbitmq']['use_distro_version'] = true
default['rabbitmq']['port'] = 5672

# Tomcat configuration
default['abiquo']['tomcat']['http-port'] = 8009
default['abiquo']['tomcat']['ajp-port'] = 8010
default['abiquo']['tomcat']['wait-for-webapps'] = false
default['abiquo']['tomcat']['alias'] = node['fqdn']

# Override the Apache proxy configuration
default['apache']['proxy']['order'] = 'allow,deny'
default['apache']['proxy']['deny_from']  = 'none'
default['apache']['proxy']['allow_from'] = 'all'

# Determine if the server should include the frontend components
# UI + websockify
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
default['abiquo']['aim']['neutron']['rabbit_password'] = 'abiquo'
default['abiquo']['aim']['neutron']['rabbit_host'] = 'localhost'
default['abiquo']['aim']['neutron']['auth_uri'] = 'http://localhost:5000/v2.0'
default['abiquo']['aim']['neutron']['identity_uri'] = 'http://localhost:35357'
default['abiquo']['aim']['neutron']['admin_tenant_name'] = 'services'
default['abiquo']['aim']['neutron']['admin_user'] = 'neutron'
default['abiquo']['aim']['neutron']['admin_password'] = 'xabiquo'

# Configure monitoring node
default['abiquo']['monitoring']['cassandra']['cluster_name'] = 'abiquo'
default['abiquo']['monitoring']['kairosdb']['version'] = '0.9.4'
default['abiquo']['monitoring']['kairosdb']['release'] = '6'
default['abiquo']['monitoring']['kairosdb']['host'] = 'localhost'
default['abiquo']['monitoring']['kairosdb']['port'] = 8080
default['abiquo']['monitoring']['rabbitmq']['host'] = 'localhost'
default['abiquo']['monitoring']['rabbitmq']['port'] = 5672
default['abiquo']['monitoring']['rabbitmq']['username'] = node['abiquo']['rabbitmq']['username']
default['abiquo']['monitoring']['rabbitmq']['password'] = node['abiquo']['rabbitmq']['password']
default['abiquo']['monitoring']['db']['host'] = 'localhost'
default['abiquo']['monitoring']['db']['port'] = 3306
default['abiquo']['monitoring']['db']['user'] = 'root'
default['abiquo']['monitoring']['db']['password'] = nil
default['abiquo']['monitoring']['db']['from'] = 'localhost'
default['abiquo']['monitoring']['db']['install'] = true
default['abiquo']['monitoring']['emmett']['port'] = 36638

# Override the default java configuration
default['java']['oracle']['accept_oracle_download_terms'] = true
default['java']['install_flavor'] = 'oracle_rpm'
default['java']['oracle_rpm']['type'] = 'jdk'
default['java']['java_home'] = '/usr/java/default'
default['java']['jdk_version'] = 8

# Override Cassandra default configuration to make sure it is always running properly
default['cassandra']['notify_restart'] = true

# Default properties
default['abiquo']['properties']['abiquo.datacenter.id'] = node['hostname']
default['abiquo']['properties']['abiquo.rabbitmq.username'] = node['abiquo']['rabbitmq']['username']
default['abiquo']['properties']['abiquo.rabbitmq.password'] = node['abiquo']['rabbitmq']['password']
default['abiquo']['properties']['abiquo.rabbitmq.host'] = '127.0.0.1'
default['abiquo']['properties']['abiquo.rabbitmq.port'] = 5672
default['abiquo']['properties']['abiquo.vncport.min'] = 5900
default['abiquo']['properties']['abiquo.vncport.max'] = 5999

case node['abiquo']['profile']
when 'monolithic', 'server'
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

# Configure Abiquo websockify
default['abiquo']['websockify']['port'] = 41338
default['abiquo']['websockify']['address'] = '127.0.0.1'
default['abiquo']['websockify']['api_url'] = 'https://localhost/api'
default['abiquo']['websockify']['conf'] = { token_expiration: 10000,
                                            ssl_verify: 'false',
                                            api_user: 'admin',
                                            api_pass: 'xabiquo' }
default['abiquo']['websockify']['crt'] = node['abiquo']['certificate']['file']
default['abiquo']['websockify']['key'] = node['abiquo']['certificate']['key_file']
default['abiquo']['haproxy']['address'] = '*'
default['abiquo']['haproxy']['port'] = 41337
default['abiquo']['haproxy']['certificate'] = "#{node['abiquo']['certificate']['file']}.haproxy.crt"
default['haproxy']['enable_default_http'] = false
