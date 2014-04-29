Abiquo Cookbook
===============

This cookbook provides several recipes to install an upgrade an Abiquo platform.
It allows to provision an Abiquo Monolithic and the Remote services from scratch, 
as long as upgrading an existing Abiquo installation using the latest nightly builds.

It targets Abiquo 3.0 or later releases.

# Requirements

* CentOS >= 6.0

This cookbook depends on the following cookbooks:

* apache2
* iptables
* java
* java-management
* redisio
* selfsigned\_certificate
* selinux
* yum

# Recipes

Generic recipes to be used to deploy an Abiquo platform from scratch:

* `recipe[abiquo]` - Installs an Abiquo Monolithic
* `recipe[abiquo::repository]` - Configures the Abiquo yum repositories
* `recipe[abiquo::install_monolithic]` - Installs an Abiquo Monolithic
* `recipe[abiquo::install_remoteservices]` - Installs the Abiquo Remote Services
* `recipe[abiquo::setup_server]` - Configures the Abiquo Server
* `recipe[abiquo::setup_remoteservices]` - Configures the Abiquo Remote Services
* `recipe[abiquo::database]` - Installs the Abiquo database

Specific recipes to upgrade existing Abiquo installations:

* `recipe[abiquo::stop]` - Stops all Abiquo services
* `recipe[abiquo::start]` - Starts all Abiquo services
* `recipe[abiquo::update]` - Updates all Abiquo packages
* `recipe[abiquo::certificate]` - Configures the SSL certificates

# Attributes

The following attributes are under the `node['abiquo']` namespace.

Attribute | Description | Type | Default
----------|-------------|------|--------
`['datacenterId']` | The value for the datacenter id property | String | Abiquo
`['nfs']['mountpoint']` | The path where the image repository is mounted | String | "/opt/vm\_repository"
`['nfs']['location']` | If set, the NFS repository to mount | String | nil
`['installdb']` | Install (and override) the database or not | Boolean | true
`['license']` | The Abiquo license to install | String | nil
`['nightly-repo']` | A yum repository with nightly builds | String | nil
`['rabbitmqhost']` | The address of the RabbitMQ server | String | "127.0.0.1"
`['redishost']` | The address of the Redis server | String | "127.0.0.1"
`['fullivirt']` | If full virtualization is used in the KVM hypervisors | Boolean | false
`['http-protocol']` | The protocol used to connect to the API ("http or "https") | String | "http"
`['tomcat-http-port']` | The port where the Tomcat listens to HTTP traffic | Integer | 8009
`['tomcat-ajp-port']` | The port where the Tomcat listens to AJP traffic | Integer | 8010
`['wait-for-webapps']` | If Chef will wait for the webapps to be running after restarting Tomcat | Boolean | false
`['ssl']['certificatefile']` | The path to the SSL certificate | String | "/etc/pki/tls/certs/ca.cert"
`['ssl']['keyfile']` | The path to the certificate's key | String | "/etc/pki/tls/private/ca.key"
`['ssl']['keystore']` | Path to the trust store for the JVM | String | "/usr/java/default/jre/lib/security/cacerts"
`['ssl']['keytool']` | Path to the keytool binary | String | "/usr/java/default/jre/bin/keytool"
`['ssl']['storepass']` | The password for the JVM trust store | String | "changeit"

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

The cookbook is pretty straightforwatd to use.

To install an Abiquo platform from scratch, include the following recipes in the run list:

* `recipe[abiquo]`

To install the Abiquo Remote Services from scratch, include the following recipes in the run list:

* `recipe[abiquo::repository]`
* `recipe[abiquo::install_remoteservices]`
* `recipe[abiquo::setup_remoteservices]`

To upgrade an existing Abiquo platform, include the following recipes (it is a good idea to create a role for this):

* `recipe[abiquo::stop]`
* `recipe[abiquo::repository]`
* `recipe[abiquo::update]`
* `recipe[abiquo::start]`
* `recipe[abiquo::setup_server]` or `recipe[abiquo::setup_remoteservices]`

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
