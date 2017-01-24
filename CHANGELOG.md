abiquo CHANGELOG
================

## 0.10.0

* Lock the version of the seabios dependency in CentOS 7 virtualized KVMs
  to bypass CentOS bug: https://bugs.centos.org/view.php?id=12632&nbn=2
* Added support for OpenStack Neutron in KVM hosts.
* Add support for CentOS 7.
* Allow to configure MariaDB as master so new slaves can replicate from it.
* Use a custom plugin for webSockify instead of the token scripts.

## 0.9.1

* The update recipe includes the default one.
* Enforce a Ruby friendly style.

## 0.9.0

* Enforce a proper Ruby style with Rubocop.
* Use HAproxy as SSL termination for Websockify.
* Use official cookbooks to install MariaDB, RabbitMQ and Redis.

## 0.8.0

* Added suppoert for RHEL >= 6.7.
* Simplified the ui configuration by leveraging only the 'ui_config' attribute.
* Added ext_services profile.
* Added front-end profile.
* Configured the monitoring resources to be idempotent.
* Fix watchtower schema creation during install and upgrade.
* Upgrade tests to Centos 6.8.
* Added ui and websockify profiles.
* Removed the Abiquo nightly repository.

## 0.7.3

* Properly restart tomcat after configuring users in RabbitMQ

## 0.7.2

* Create the monitoring schema when installing the monitoring nodes

## 0.7.1

* Cookbook metadata fixes

## 0.7.0

* Install the websockify package for VM remote access.
* Configure an Abiquo user in RabbitMQ
* Added the EPEL repository.
* Configured resources to be idempotent and avoid unwanted restarts.
* Configure a generic recipe to manage teh Abiquo Tomcat service.
* Better management for SSL certificates.
* Remove the need for the ark cookbook.
* Monitoring nodes can be upgraded
* Install Watchtower services in the monitoring node

## 0.6.0

* Added custom firewall templates for each profile.
* General recipe refactor to include the 'server' and 'v2v' profiles.
* Created a Kitchen suite to use nightly build branches. 

## 0.5.0

* Configured the firewall in the kvm profile.
* Upgrade the database using the abiquo-liquibase script.
* Added integration tests with ServerSpec.
* Added a recipe to install a monitoring node.
* Upgraded base repositories to 3.6.

## 0.4.0

* Use the rpm signing keys from the abiquo-release-ee package.

## 0.3.3

* Removed the start, stop and update recipes.
* Changed the upgrade recipe to also upgrade the database.
* Added database configuration attributes.

## 0.3.2

* Added the abiquo-updates yum repository.
* Configured the rpm GPG sign keys that are not present in the abiquo-release-ee package.
* Fixed encofing in the UI configuration file.

## 0.3.1

* Fixed the NFS resource.

## 0.3.0

* Added support for Abiquo 3.3.

## 0.2.1

* Install Java and RabbitMQ from the Abiquo repositories.
* Added all missing signatures to the repository configuration.
* Configured the cookbook to install Abiquo 3.3.

## 0.2.0

* Support Java 8.
* Support using JCE unlimited strength encryption policies.
* Allow customization of the RabbitMQ and Redis properties.
* Dropped support to configure the Abiquo Tomcat in jpda mode.
* Redis is installed from the Abiquo packages.

## 0.1.0

* Initial release. Support for Monolithic installations from scratch and platform upgrades using nightly builds.
