Abiquo Cookbook
===============

This is a cookbook to install the Abiquo platform. It is intended for 3.0 or later versions.

# Requirements

* CentOS >= 6.0

This cookbook depends on the following cookbooks:

* apache2
* java
* java-management
* redisio
* selfsigned\_certificate
* yum

# Recipes

Generic recipes to be used to deploy an Abiquo platform from scratch:

* `recipe[abiquo]` - Installs an Abiquo Monolithic
* `recipe[abiquo::repository]` - Configures the Abiquo yum repositories
* `recipe[abiquo::system]` - Installs the Abiquo base system
* `recipe[abiquo::configure]` - Configures the Abiquo platform
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
['datacenterId'] | The value for the datacenter id property | String | Abiquo
['nfs']['mountpoint'] | The path where the image repository is mounted | String | "/opt/vm\_repository"
['nfs']['location'] | If set, the NFS repository to mount | String | nil
['installdb'] | Wether to install (and override) the database or not | Boolean | true
['license'] | The Abiquo license to install | String | nil
['nightly-repo'] | A yum repository with nightly builds | String | nil
['http-protocol'] | The protocol used to connect to the API ("http or "https") | String | "http"
['tomcat-http-port'] | The port where the Tomcat listens to HTTP traffic | Integer | 8009
['tomcat-ajp-port'] | The port where the Tomcat listens to AJP traffic | Integer | 8010
['wait-for-webapps'] | If Chef will wait for the webapps to be running after restarting Tomcat | Boolean | false
['ssl'][´certificatefile'] | The path to the SSL certificate | String | "/etc/pki/tls/certs/ca.cert"
['ssl'][´keyfile'] | The path to the certificate's key | String | "/etc/pki/tls/private/ca.key"
['ssl']['keystore'] | Path to the trust store for the JVM | String | "/usr/java/default/jre/lib/security/cacerts"
['ssl']['keytool'] | Path to the keytool binary | String | "/usr/java/default/jre/bin/keytool"
['ssl']['storepass'] | The password for the JVM trust store | String | "changeit"

# Resources and providers

The Abiquo cookbook provides the following LWRPs:

* `abiquo_wait_for_webapp` - Waits until a configured webapp is started

### Example

    abiquo\_wait\_for\_webapp "api" do
        host "localhost"
        port 8009
        retries 3   # Retry if Tomcat is still not started
        retry_delay 5
        action :wait
    end

# Usage

The cookbook is pretty straightforwatd to use.

To install an Abiquo platform from scratch, include the following recipes in the run list:

* `recipe[abiquo]`

To upgrade an existing Abiquo platform, include the following recipes (it is a good idea to create a role for this):

* `recipe[abiquo::repository]`
* `recipe[abiquo::stop]`
* `recipe[abiquo::update]`
* `recipe[abiquo::start]`
* `recipe[abiquo::configure]`

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
