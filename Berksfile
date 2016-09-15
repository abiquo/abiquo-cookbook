source 'https://supermarket.chef.io'

metadata

# Make sure we use a compatible version of the compat_resource cookbook
cookbook 'compat_resource', '~> 12.10.6'

# Used to register a node in RHN and unregister
# after run for kitchen tests.
cookbook 'rhn_register', path: 'test/fixtures/cookbooks/rhn_register', group: 'test'
