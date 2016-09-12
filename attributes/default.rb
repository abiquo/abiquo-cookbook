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
default['abiquo']['profile'] = "monolithic"

# Wether or not to install external dependant services
# like MariaDB, Redis, RabbitMQ
# Set to false if you wish to use existing servers.
default['abiquo']['install_ext_services'] = true

# Common properties
default['abiquo']['license'] = nil

# NFS repository configuration
default['abiquo']['nfs']['mountpoint'] = "/opt/vm_repository"
default['abiquo']['nfs']['location'] = nil  # Change to something like: "127.0.0.1:/opt/vm_repository"

# Yum repository configuration
default['abiquo']['yum']['base-repo'] = "http://mirror.abiquo.com/abiquo/3.8/os/x86_64"
default['abiquo']['yum']['updates-repo'] = "http://mirror.abiquo.com/abiquo/3.8/updates/x86_64"
default['abiquo']['yum']['gpg-check'] = true
default['abiquo']['yum']['proxy'] = nil

# Database configuration
default['abiquo']['db']['host'] = "localhost"
default['abiquo']['db']['port'] = 3306
default['abiquo']['db']['user'] = "root"
default['abiquo']['db']['password'] = nil
default['abiquo']['db']['upgrade'] = true

# Tomcat configuration 
default['abiquo']['tomcat']['http-port'] = 8009
default['abiquo']['tomcat']['ajp-port'] = 8010
default['abiquo']['tomcat']['wait-for-webapps'] = false

# UI Apache configuration
default['abiquo']['ui_apache_opts'] = {}

# UI app configuration attributes. These attributes will be rendered
# in /var/www/html/ui/config/client-config-custom.json
default['abiquo']['ui_config'] = { "config.endpoint" => "https://#{node['fqdn']}/api" }

case node['abiquo']['profile']
when 'monolithic'
    default['abiquo']['ui_proxies'] = { '/am' => "ajp://localhost:#{node['abiquo']['tomcat']['ajp-port']}/am" }
else
    default['abiquo']['ui_proxies'] = {}
end

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

# Configure abiquo KVM
default['abiquo']['aim']['port'] = 8889

# Configure monitoring node
default['abiquo']['monitoring']['cassandra']['cluster_name'] = 'abiquo'
default['abiquo']['monitoring']['kairosdb']['version'] = '0.9.4'
default['abiquo']['monitoring']['kairosdb']['release'] = '6'
default['abiquo']['monitoring']['kairosdb']['host'] = 'localhost'
default['abiquo']['monitoring']['kairosdb']['port'] = 8080
default['abiquo']['monitoring']['rabbitmq']['host'] = 'localhost'
default['abiquo']['monitoring']['rabbitmq']['port'] = 5672
default['abiquo']['monitoring']['rabbitmq']['username'] = 'abiquo'
default['abiquo']['monitoring']['rabbitmq']['password'] = 'abiquo'
default['abiquo']['monitoring']['db']['host'] = 'localhost'
default['abiquo']['monitoring']['db']['port'] = 3306
default['abiquo']['monitoring']['db']['user'] = 'root'
default['abiquo']['monitoring']['db']['password'] = ''
default['abiquo']['monitoring']['db']['install'] = true
default['abiquo']['monitoring']['emmett']['port'] = 36638

# Override the Apache proxy configuration
override['apache']['proxy']['order'] = "allow,deny"
override['apache']['proxy']['deny_from']  = "none"
override['apache']['proxy']['allow_from'] = "all"

# Override the default java configuration
# TODO: Configure these attributes in a way that they don't have precedence over user config
override['java']['oracle']['accept_oracle_download_terms'] = true
override['java']['java_home'] = "/usr/java/default"
override['java']['jdk_version'] = 8

# Override Cassandra default configuration to make sure it is always running properly
override['cassandra']['notify_restart'] = true

# Default properties
default['abiquo']['properties']['abiquo.datacenter.id'] = node['hostname']
default['abiquo']['properties']['abiquo.rabbitmq.username'] = 'abiquo'
default['abiquo']['properties']['abiquo.rabbitmq.password'] = 'abiquo'
default['abiquo']['properties']['abiquo.rabbitmq.host'] = '127.0.0.1'
default['abiquo']['properties']['abiquo.rabbitmq.port'] = 5672
default['abiquo']['properties']['abiquo.vncport.min'] = 6000
default['abiquo']['properties']['abiquo.vncport.max'] = 6999

case node['abiquo']['profile']
when "monolithic", "server"
    default['abiquo']['properties']['abiquo.m.identity'] = 'default_outbound_api_user'
    default['abiquo']['properties']['abiquo.server.sessionTimeout'] = 30
    default['abiquo']['properties']['abiquo.server.mail.server'] = '127.0.0.1'
    default['abiquo']['properties']['abiquo.server.mail.user'] = 'none@none.es'
    default['abiquo']['properties']['abiquo.server.mail.password'] = 'none'
    default['abiquo']['properties']['abiquo.redis.host'] = '127.0.0.1'
    default['abiquo']['properties']['abiquo.redis.port'] = 6379
    default['abiquo']['properties']['abiquo.monitoring.enabled'] = false
    default['abiquo']['properties']['abiquo.server.api.location'] = "https://#{node['fqdn']}/api"
when "remoteservices"
    default['abiquo']['properties']['abiquo.appliancemanager.localRepositoryPath'] = node['abiquo']['nfs']['mountpoint']
    default['abiquo']['properties']['abiquo.appliancemanager.checkMountedRepository'] = !node['abiquo']['nfs']['location'].nil?
    default['abiquo']['properties']['abiquo.monitoring.enabled'] = false
end

# Configure Abiquo websockify
default['abiquo']['websockify']['port'] = 41337
default['abiquo']['websockify']['api_url'] = 'https://localhost/api'
default['abiquo']['websockify']['user'] = 'admin'
default['abiquo']['websockify']['pass'] = 'xabiquo'
default['abiquo']['websockify']['crt']  = node['abiquo']['certificate']['file']
default['abiquo']['websockify']['key']  = node['abiquo']['certificate']['key_file']

