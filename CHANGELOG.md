abiquo CHANGELOG
================

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
