name             'abiquo'
maintainer       'Abiquo'
maintainer_email 'ignasi.barrera@abiquo.com'
license          'Apache-2.0'
description      'Installs and configures an Abiquo platform'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
source_url       'https://github.com/abiquo/abiquo-cookbook'
issues_url       'https://github.com/abiquo/abiquo-cookbook/issues'
version          '0.18.0'
chef_version     '~> 14.8'

recipe 'abiquo', 'Installs and configures an Abiquo platform'
recipe 'abiquo::repository', 'Configures the Abiquo yum repositories'
recipe 'abiquo::install_monolithic', 'Installs the Abiquo Monolithic packages'
recipe 'abiquo::install_remoteservices', 'Installs the Abiquo Remote Services'
recipe 'abiquo::install_server', 'Installs the Abiquo Management Server'
recipe 'abiquo::install_v2v', 'Installs an standalone V2V server'
recipe 'abiquo::install_kvm', 'Installs a KVM hypervisor'
recipe 'abiquo::install_monitoring', 'Installs an Abiquo monitoring node with a Cassandra backed KairosDB'
recipe 'abiquo::install_frontend', 'Installs an Abiquo frontend components'
recipe 'abiquo::install_mariadb', 'Installs the MariaDB database'
recipe 'abiquo::install_rabbitmq', 'Installs the RabbitMQ message broker'
recipe 'abiquo::install_redis', 'Installs the Redis database'
recipe 'abiquo::setup_monolithic', 'Configures and starts the Abiquo Platform'
recipe 'abiquo::setup_remoteservices', 'Configures and starts the Abiquo Remote Services'
recipe 'abiquo::setup_server', 'Configures the Abiquo Management Server'
recipe 'abiquo::setup_v2v', 'Configures an standalone V2V server'
recipe 'abiquo::setup_kvm', 'Configures a KVM hypervisor'
recipe 'abiquo::setup_monitoring', 'Configures and starts the Abiquo monitoring services'
recipe 'abiquo::setup_frontend', 'Configures the Abiquo frontend components'
recipe 'abiquo::kvm_neutron', 'Configures a KVM hypervisor to use OpenStack Neutron for SDN'
recipe 'abiquo::upgrade', 'Upgrades an Abiquo platform'
recipe 'abiquo::install_database', 'Creates the Abiquo database'
recipe 'abiquo::install_ext_services', 'Installs Abiquo supporting services (MariaDB, RabbitMQ, Redis)'
recipe 'abiquo::certificate', 'Installs a custom SSL certificate in the Apache'
recipe 'abiquo::service', 'Manages Abiquo tomcat service'

supports 'centos', '>= 7.5'
supports 'redhat', '>= 7.5'

depends 'apache2', '~> 5.2'
depends 'cassandra-dse', '~> 4.4.0'
depends 'iptables', '~> 2.0.1'
depends 'java', '~> 1.46.0'
depends 'java-management', '~> 1.0.3'
depends 'selinux', '~> 2.1.1'
depends 'ssl_certificate', '~> 2.1.0'
depends 'yum', '~> 3.10.0'
depends 'yum-epel', '~> 0.6.5'
depends 'redisio', '~> 3.0.0'
depends 'mariadb', '~> 1.0.1'
depends 'mysql2_chef_gem', '~> 2.1.0'
depends 'rabbitmq', '~> 5.7.3'
depends 'sysctl', '~> 0.8.1'
depends 'kernel-modules', '~> 2.0.3'
depends 'mysql2_chef_gem', '~> 2.1.0'
