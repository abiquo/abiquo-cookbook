name             'abiquo'
maintainer       'Abiquo'
maintainer_email 'ignasi.barrera@abiquo.com'
license          'Apache 2.0'
description      'Installs and configures an Abiquo 3.0 Monolithic'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

recipe 'abiquo', 'Installs and configures an Abiquo 3.0 Monolithic'
recipe 'abiquo::repository', 'Configures the Abiquo yum repositories'
recipe 'abiquo::system', 'Installs the Abiquo system packages'
recipe 'abiquo::configure', 'Configures and starts the Abiquo platform'
recipe 'abiquo::update', 'Updates the platform to the latest packages'
recipe 'abiquo::database', 'Creates the Abiquo database'

supports 'centos', '>= 6.0'

depends 'apache2'
depends 'java'
depends 'redisio'
depends 'yum'
