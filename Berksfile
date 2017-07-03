source 'https://supermarket.chef.io'

metadata

# Used to register a node in RHN and unregister after run for kitchen tests.
cookbook 'rhn_register', path: 'test/fixtures/cookbooks/rhn_register', group: 'test'

# Contains the fixes needed to the systemd notifications in the C* cookbook. Remove this
# when https://github.com/michaelklishin/cassandra-chef-cookbook/pull/353 is merged and
# there is a release of the cookbook.
cookbook 'cassandra-dse', git: 'https://github.com/nacx/cassandra-chef-cookbook.git', branch: 'systemd-fixes'
