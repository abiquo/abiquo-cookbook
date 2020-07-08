
## Setup
**Ubuntu 20.04**
```
sudo apt-get install ruby-mysql libmysqlclient-dev
```



Testing
=======

In order to test the cookbook you will need to install [Vagrant](https://www.vagrantup.com/) and [VirtualBox](https://www.virtualbox.org/). 

The cookbook has been tested on the following platforms:

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
