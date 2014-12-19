name             'abiquo'
maintainer       'Abiquo'
maintainer_email 'ignasi.barrera@abiquo.com'
license          'Apache 2.0'
description      'Installs and configures an Abiquo platform'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.3.3'

recipe 'abiquo', 'Installs and configures an Abiquo platform'
recipe 'abiquo::upgrade', 'Upgrades an Abiquo platform'
recipe 'abiquo::repository', 'Configures the Abiquo yum repositories'
recipe 'abiquo::install_monolithic', 'Installs the Abiquo Monolithic packages'
recipe 'abiquo::install_remoteservices', 'Installs the Abiquo Remote Services'
recipe 'abiquo::install_kvm', 'Installs a KVM hypervisor'
recipe 'abiquo::setup_monolithic', 'Configures and starts the Abiquo Platform'
recipe 'abiquo::setup_remoteservices', 'Configures and starts the Abiquo Remote Services'
recipe 'abiquo::setup_kvm', 'Configures a KVM hypervisor'
recipe 'abiquo::update_packages', 'Updates the platform to the latest packages'
recipe 'abiquo::database', 'Creates the Abiquo database'
recipe 'abiquo::certificate', 'Installs a custom SSL certificate in the Apache'
recipe 'abiquo::stop', 'Stops all Abiquo services'
recipe 'abiquo::start', 'Starts all Abiquo services'
recipe 'abiquo::install_jce', 'Installs the JCE unlimited strength jurisdiction policy files'

supports 'centos', '>= 6.5'

depends 'apache2'
depends 'ark'
depends 'iptables'
depends 'java-management'
depends 'selfsigned_certificate'
depends 'selinux'
depends 'yum'

suggests 'hostname'
suggests 'postfix'
