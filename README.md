Abiquo Cookbook
===============

[![Build Status](https://travis-ci.org/abiquo/abiquo-cookbook.svg?branch=master)](https://travis-ci.org/abiquo/abiquo-cookbook)
[![Abiquo Cookbook](http://img.shields.io/badge/cookbook-v0.7.2-blue.svg?style=flat)](https://supermarket.chef.io/cookbooks/abiquo)
[![Chef Version](http://img.shields.io/badge/chef-v12.5.1-orange.svg?style=flat)](https://www.chef.io)

This cookbook provides several recipes to install an upgrade an Abiquo platform.
It allows to provision an Abiquo Server, the Remote Services server, standalone V2V
server, monitoring server and a KVM hypervisor from scratch, as long as upgrading 
an existing Abiquo installation using the latest nightly builds.

# Requirements

* CentOS >= 6.7

This cookbook depends on the following cookbooks:

* apache2
* cassandra-dse
* iptables
* java
* java-management
* selinux
* ssl_certificate
* yum

# Recipes

The cookbook contains the following recipes:

* `recipe[abiquo]` - Installs an Abiquo Platform
* `recipe[abiquo::repository]` - Configures the Abiquo yum repositories
* `recipe[abiquo::install_monolithic]` - Installs an Abiquo Monolithic
* `recipe[abiquo::install_server]` - Installs an Abiquo Server
* `recipe[abiquo::install_remoteservices]` - Installs the Abiquo Remote Services
* `recipe[abiquo::install_v2v]` - Installs an standalone V2V Server
* `recipe[abiquo::install_kvm]` - Installs the KVM hypervisor
* `recipe[abiquo::install_monitoring]` - Installs an Abiquo Monitoring node with Cassandra and kairosDB
* `recipe[abiquo::setup_monolithic]` - Configures the Abiquo Monolithic Server
* `recipe[abiquo::setup_server]` - Configures the Abiquo Server
* `recipe[abiquo::setup_remoteservices]` - Configures the Abiquo Remote Services
* `recipe[abiquo::setup_v2v]` - Configures an standalone V2V Server
* `recipe[abiquo::setup_kvm]` - Configures the KVM hypervisor
* `recipe[abiquo::setup_monitoring]` - Configures the Abiquo Monitoring node
* `recipe[abiquo::upgrade]` - Upgrades an Abiquo Platform
* `recipe[abiquo::install_database]` - Installs the Abiquo database
* `recipe[abiquo::install_ext_services]` - Installs the Abiquo supporting services like Redis, RabbitMQ, etc.
* `recipe[abiquo::certificate]` - Configures the SSL certificates
* `recipe[abiquo::service]` - Manages Abiquo tomcat service

# Attributes

The following attributes are under the `node['abiquo']` namespace.

Attribute | Description | Type | Default
----------|-------------|------|--------
`['profile']` | The profile to install: "monolithic", "server", "remoteservices", "v2v", "kvm" or "monitoring" | String | "monolithic"
`['install_ext_services']` | Whether or not to install supporting services like MariaDB, Redis, RabbitMQ, etc. | Boolean | true
`['ui_address_type']` | The attribute to use as the Abiquo UI address: "fqdn", "ipaddress", "fixed" | String | "fqdn"
`['ui_address']` | When `['ui_address_type']` is `fixed` use this as address | String | node['fqdn']
`['nfs']['mountpoint']` | The path where the image repository is mounted | String | "/opt/vm\_repository"
`['nfs']['location']` | If set, the NFS repository to mount | String | nil
`['license']` | The Abiquo license to install | String | nil
`['properties']` | Hash with additional Abiquo properties to add to the Abiquo configuration file | Hash | {}
`['yum']['base-repo']` | The main Abiquo yum repository | String | "http://mirror.abiquo.com/abiquo/3.6/os/x86_64"
`['yum']['update-repo']` | The Abiquo updates yum repository | String | "http://mirror.abiquo.com/abiquo/3.6/updates/x86_64"
`['yum']['nightly-repo']` | A yum repository with nightly builds | String | nil
`['db']['host']` | The database host used when running the database upgrade | String | "localhost""
`['db']['port']` | The database port used when running the database upgrade | Integer | 3306
`['db']['user']` | The database user used when running the database upgrade | String | "root"
`['db']['password']` | The database password used when running the database upgrade | String | nil
`['db']['upgrade']` | Run the database upgrade when upgrading the monolithic profile | Boolean | true
`['aim']['port']` | In a KVM, the port where the Abiquo AIM agent will listen | Integer | 8889
`['tomcat']['http-port']` | The port where the Tomcat listens to HTTP traffic | Integer | 8009
`['tomcat']['ajp-port']` | The port where the Tomcat listens to AJP traffic | Integer | 8010
`['tomcat']['wait-for-webapps']` | If Chef will wait for the webapps to be running after restarting Tomcat | Boolean | false
`['monitoring']['kairosdb']['host']` | The host where KairosDB is listening | Integer | "localhost"
`['monitoring']['kairosdb']['port']` | The port where KairosDB is listening | Integer | 8080
`['monitoring']['kairosdb']['version']` | The version of KairosDB to install in the monitoring node | String | "0.9.4"
`['monitoring']['kairosdb']['release']` | The release of the configured KairosDB version to install in the monitoring node | String | "6"
`['monitoring']['db']['host']` | The monitoring database host | String | "localhost"
`['monitoring']['db']['port']` | The monitoring database port | Integer | 3306
`['monitoring']['db']['user']` | The monitoring database user | String | "root"
`['monitoring']['db']['password']` | The monitoring database password | String | ""
`['monitoring']['db']['install']` | Install the monitoring database when installing the monitoring node | Boolean | true
`['monitoring']['rabbitmq']['host']` | The RabbitMQ host where the monitoring system will notify alerts | String | "localhost"
`['monitoring']['rabbitmq']['port']` | The RabbitMQ listening port for the monitoring system notifications | Integer | 5672 
`['monitoring']['rabbitmq']['user']` | The RabbitMQ user for the monitoring system notifications | String | "guest"
`['monitoring']['rabbitmq']['password']` | The RabbitMQ password for the monitoring system notifications | String | "guest"
`['monitoring']['emmett']['port']` | The port where the Emmett service is listening | Integer | 36638
`['monitoring']['cassandra']['cluster_name']` | The name for the Cassandra cluster in the monitoring node | String | "abiquo"
`['certificate']['common_name']` | Common name for the generated certificate | String | node['fqdn']
`['certificate']['organization']` | Organization for the generated certificate | String | "Abiquo"
`['certificate']['department']` | Department for the generated certificate | String | "Engineering"
`['certificate']['country']` | Country for the generated certificate | String | "ES"
`['certificate']['source']` | Source for the generated certificate | String | "self-signed"
`['certificate']['file']` | If `['certificate']['file']` is false, use this file as certificate | String | '/etc/pki/tls/certs/localhost.crt'
`['certificate']['key_file']` | If `['certificate']['file']` is false, use this file as the certificate private key | String | '/etc/pki/tls/private/localhost.key'
`['certificate']['ca_file']` | If `['certificate']['file']` is false, use this file as tha CA certificate | String | nil

# Resources and providers

The Abiquo cookbook provides the following LWRPs:

## abiquo\_wait\_for\_webapp

This LWRP will make the Chef run wait until the configured webapp is started.

### Parameters

* `host` - The address where the webapp is running
* `port` - The port where the webapp is listening
* `webapp` - The name of the webapp
* `open_timeout` - The timeout to open a connection to the webapp
* `read_timeout` - The timeout to read from a connection to the webapp

### Example

    abiquo_wait_for_webapp "api" do
        host "localhost"
        port 8009
        retries 3   # Retry if Tomcat is still not started
        retry_delay 5
        action :wait
    end

## abiquo\_wait\_for\_port

This LWRP will make the Chef run wait until the configured port is open.

### Parameters

* `host` - The address where the service is running
* `port` - The port where the service is listening
* `service` - The name of the service
* `delay` - The delay in seconds between retries
* `timeout` - The timeout for a connection to be considered failed

### Example

    abiquo_wait_for_port "cassandra" do
        host "localhost"
        port 9160
        delay 10
        timeout 5
        action :wait
    end

# Usage

The cookbook is pretty straightforwatd to use. Just set the `node['abiquo']['profile']` attribute
according to the profile you want to install or upgrade and and include one of the following recipes
in the run list:

* `recipe[abiquo]` - To perform an installation from scratch
* `recipe[abiquo::upgrade]` - To upgrade an existing installation

The available profiles are: `monolithic`, `remoteservices`, `server`, `v2v`, `kvm` and `monitoring`.

When installing the Abiquo Monolithic profile, you may also want to set the `node['abiquo']['certificate']`
properties so the right certificate is used or a self-signed one is generated. You can also use it together
with the [hostname](http://community.opscode.com/cookbooks/hostname) cookbook to make sure the node will have it properly configured.

# Testing

In order to test the cookbook you will need to install [Vagrant](https://www.vagrantup.com/) and [VirtualBox](https://www.virtualbox.org/).
Once installed you can run the unit and integration tests as follows:

    bundle install
    bundle exec rake          # Run the unit and style tests
    bundle exec rake kitchen  # Run the integration tests

The tests and Gemfile have been developed using Ruby 2.1.5, and that is the recommended Ruby version to use to run the tests.
Other versions may cause conflicts with the versions of the gems Bundler will install.

# License and Authors

* Author:: Ignasi Barrera (ignasi.barrera@abiquo.com)
* Author:: Marc Cirauqui (marc.cirauqui@abiquo.com)

Copyright:: 2014, Abiquo

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
