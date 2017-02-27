Abiquo Cookbook
===============

[![Build Status](https://travis-ci.org/abiquo/abiquo-cookbook.svg?branch=master)](https://travis-ci.org/abiquo/abiquo-cookbook)
[![Abiquo Cookbook](http://img.shields.io/badge/cookbook-v0.11.0-blue.svg?style=flat)](https://supermarket.chef.io/cookbooks/abiquo)
[![Chef Version](http://img.shields.io/badge/chef-v12.16.42-orange.svg?style=flat)](https://www.chef.io)

This cookbook provides several recipes to install and upgrade an Abiquo platform.
It allows you to provision an Abiquo Server, the Remote Services server, standalone V2V
server, monitoring server, frontend components and a KVM hypervisor from scratch,
as long as upgrading an existing Abiquo installation.

# Usage

The cookbook is pretty straightforwatd to use. Just set the `node['abiquo']['profile']` attribute
according to the profile you want to install or upgrade and and include one of the following recipes
in the run list:

* `recipe[abiquo]` - To perform an installation from scratch
* `recipe[abiquo::upgrade]` - To upgrade an existing installation

The available profiles are: 

- `monolithic` sets up all Abiquo components in one host.
- `remoteservices` sets up the Abiquo remote services (except V2V).
- `server` sets up the Abiquo management components (API, M) plus the frontend components (UI, websockify).
- `ui` sets up the Abiquo UI.
- `websockify` sets up the Websockify proxy for noVNC connections.
- `frontend` sets up the frontend components, UI and Websockify.
- `v2v` sets up the Abiquo V2V conversion manager.
- `kvm` sets up an Abiquo KVM cloud node.
- `monitoring` sets up the monitoring components of the Abiquo platform
- `ext_services` sets up the management components' supporting databases (MariaDB, Redis) and the RabbitMQ message bus.

When installing the Abiquo Monolithic profile, you may also want to set the `node['abiquo']['certificate']`
properties so the right certificate is used or a self-signed one is generated. You can also use it together
with the [hostnames](http://community.opscode.com/cookbooks/hostnames) cookbook to make sure the node will have it properly configured.

# Testing

In order to test the cookbook you will need to install [Vagrant](https://www.vagrantup.com/) and [VirtualBox](https://www.virtualbox.org/). 

* Tested on:

| Operating System | Vagrant version | VirtualBox version |
|---|---|---|
| Fedora 25 |  1.8.5 | 5.1.14r112924 |
| OS X 10.12.2 | 1.9.1 | 5.0.32r112930 |

Once installed you can run the unit and integration tests as follows:

    bundle install
    bundle exec berks         # Install the cookbook dependencies
    bundle exec rake          # Run the unit and style tests
    bundle exec rake kitchen  # Run the integration tests

The tests and Gemfile have been developed using Ruby 2.2.5, and that is the recommended Ruby version to use to run the tests.
Other versions may cause conflicts with the versions of the gems Bundler will install.

## RHEL testing

Integration tests for RHEL are specified in a separate ```.kitchen.rhel.yml``` file. They use a vagrant box named ```rhel-6.8``` which you will need to build and add to the host running the tests as described in [bento project repository](https://github.com/chef/bento).

Once the box is available in the host, you can run the tests by specifying the kitchen config file to use and the user and password so the VM can register to RedHat and get a subscription.

```
$ KITCHEN_LOCAL_YAML=.kitchen.rhel.yml RHN_USERNAME=some_user RHN_PASSWORD=some_pass bundle exec rake kitchen-basic
```

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
