name             'rhn_register'
maintainer       'Abiquo'
maintainer_email 'marc.cirauqui@abiquo.com'
license          'Apache 2.0'
description      'Registers and unregisters a node from RHN'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.0.1'

recipe 'rhn_register::register', 'Installs and configures an Abiquo platform'
recipe 'rhn_register::unregister', 'Installs and configures an Abiquo platform'

supports 'redhat', '>= 6.7'

depends 'redhat_subscription_manager', '~> 0.5.0'
