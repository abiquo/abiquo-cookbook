source 'https://supermarket.chef.io'

metadata

# Make sure we use a compatible version of the compat_resource cookbook
cookbook 'compat_resource', '~> 12.10.6'

# Used to install RabbitMQ when testing the monitoring
# recipe with kitchen.
cookbook 'rabbitmq', '= 4.6.0', group: 'test'

# Test cookbook for RHEL systems
cookbook 'rhel_subscription', path: 'test/fixtures/cookbooks/rhel_subscription', group: 'test'