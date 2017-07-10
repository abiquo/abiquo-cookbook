Abiquo Cookbook
===============

[![Build Status](https://travis-ci.org/abiquo/abiquo-cookbook.svg?branch=master)](https://travis-ci.org/abiquo/abiquo-cookbook)
[![Abiquo Cookbook](http://img.shields.io/badge/cookbook-v0.11.3-blue.svg?style=flat)](https://supermarket.chef.io/cookbooks/abiquo)
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

Detailed instructions to run the different test suites in the supported platforms can be found in the [TESTING.md](TESTING.md) file.

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
