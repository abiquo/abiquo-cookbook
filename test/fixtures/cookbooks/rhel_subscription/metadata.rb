name             'rhel_subscription'
maintainer       'Abiquo'
maintainer_email 'marc.cirauqui@abiquo.com'
license          'Apache 2.0'
description      'Registers and unregisters a RHEL server from RedHat'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

supports 'redhat', '>= 6.5'

depends 'redhat_subscription_manager', '~> 0.1'
