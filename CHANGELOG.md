magentostack CHANGELOG
==================


0.0.1
-----

- @martinb3 - Add Apache vhost, cleanup testing for things we didn't converge
- @martinb3 - Remove return on missing attribute
- @martinb3 - Could not pass testing with listen_ports mixing node.default and node.set
- @martinb3 - Remove template for magentostack.ini, since actual source file was already removed
- @martinb3 - Switch to node.deep_fetch with additional guards, since some of the attributes were removed here
- @martinb3 - s/phpstack/magentostack/g everywhere
