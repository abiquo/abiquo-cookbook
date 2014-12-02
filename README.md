Abiquo Cookbook
===============

This cookbook provides several recipes to install an upgrade an Abiquo platform.
It allows to provision an Abiquo Monolithic, the Remote Services and a KVM hypervisor
from scratch, as long as upgrading an existing Abiquo installation using the latest
nightly builds.

It targets Abiquo 3.2 or later releases.

# Requirements

* CentOS >= 6.0

This cookbook depends on the following cookbooks:

* apache2
* ark
* iptables
* java
* java-management
* selfsigned\_certificate
* selinux
* yum

# Recipes

Generic recipes to be used to deploy an Abiquo platform from scratch:

* `recipe[abiquo]` - Installs an Abiquo Platform
* `recipe[abiquo::upgrade]` - Upgrades an Abiquo Platform
* `recipe[abiquo::repository]` - Configures the Abiquo yum repositories
* `recipe[abiquo::install_monolithic]` - Installs an Abiquo Monolithic
* `recipe[abiquo::install_remoteservices]` - Installs the Abiquo Remote Services
* `recipe[abiquo::install_kvm]` - Installs the KVM hypervisor
* `recipe[abiquo::setup_monolithic]` - Configures the Abiquo Server
* `recipe[abiquo::setup_remoteservices]` - Configures the Abiquo Remote Services
* `recipe[abiquo::setup_kvm]` - Configures the KVM hypervisor
* `recipe[abiquo::database]` - Installs the Abiquo database
* `recipe[abiquo::install_jce]` - Installs the JCE unlimited strength jurisdiction policy files

Specific recipes to upgrade existing Abiquo installations:

* `recipe[abiquo::stop]` - Stops all Abiquo services
* `recipe[abiquo::start]` - Starts all Abiquo services
* `recipe[abiquo::update_packages]` - Updates all Abiquo packages
* `recipe[abiquo::certificate]` - Configures the SSL certificates

# Attributes

The following attributes are under the `node['abiquo']` namespace.

Attribute | Description | Type | Default
----------|-------------|------|--------
`['profile']` | The profile to install: "monolithic", "remoteservices" or "kvm" | String | "monolithic"
`['datacenterId']` | The value for the datacenter id property | String | "Abiquo"
`['nfs']['mountpoint']` | The path where the image repository is mounted | String | "/opt/vm\_repository"
`['nfs']['location']` | If set, the NFS repository to mount | String | nil
`['installdb']` | Install (and override) the database or not | Boolean | true
`['license']` | The Abiquo license to install | String | nil
`['yum']['repository']` | The main Abiquo yum repository | String | "http://mirror.abiquo.com/abiquo/3.0/os/x86\_64"
`['yum']['nightly-repo']` | A yum repository with nightly builds | String | nil
`['rabbitmq']['host']` | The address of the RabbitMQ server | String | "127.0.0.1"
`['rabbitmq']['port']` | The port of the RabbitMQ server | Integer | 5672
`['rabbitmq']['user']` | The username of the RabbitMQ server | String | "guest"
`['rabbitmq']['password']` | The password of the RabbitMQ server | String | "guest"
`['redis']['host']` | The address of the Redis server | String | "127.0.0.1"
`['redis']['port']` | The port of the Redis server | Integer | 6379
`['kvm']['fullvirt']` | If full virtualization is used in the KVM hypervisors | Boolean | false
`['aim']['port']` | In a KVM, the port where the Abiquo AIM agent will listen | Integer | 8889
`['tomcat']['http-port']` | The port where the Tomcat listens to HTTP traffic | Integer | 8009
`['tomcat']['ajp-port']` | The port where the Tomcat listens to AJP traffic | Integer | 8010
`['tomcat']['wait-for-webapps']` | If Chef will wait for the webapps to be running after restarting Tomcat | Boolean | false
`['ssl']['certificatefile']` | The path to the SSL certificate | String | "/etc/pki/tls/certs/ca.cert"
`['ssl']['keyfile']` | The path to the certificate's key | String | "/etc/pki/tls/private/ca.key"

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

## abiquo\_nfs

This LWRP allows to configure the Abiquo image repository, taking care of removing any
existing repository configuration that could already exist.

### Parameters

* `mountpoint` - The path where the repository will be mounted
* `share` - The NFS share to be configured
* `oldshare` - The name of an already configured share, if it has to be removed first.

### Example

    abiquo_nfs "/opt/vm_repository" do
        share "10.60.1.104:/volume1/nfs-devel"
        oldshare "10.60.1.72:/opt/vm_repository"
        action :configure
    end

# Usage

The cookbook is pretty straightforwatd to use. Just set the `node['abiquo']['profile']` attribute
according to the profile you want to install or upgrade and and include one of the following recipes
in the run list:

* `recipe[abiquo]` - To perform an installation from scratch
* `recipe[abiquo::upgrade]` - To upgrade an existing installation

When installing the Abiquo Monolithic profile, you may also want to set the `node['selfsigned_certificate']['cn']`
attribute to match the hostname of the node. You can also use it together with the [hostname](http://community.opscode.com/cookbooks/hostname) cookbook to make sure the node will have it properly configured.

# License and Authors

* Author:: Ignasi Barrera (ignasi.barrera@abiquo.com)

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
