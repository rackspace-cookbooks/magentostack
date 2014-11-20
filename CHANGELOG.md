magentostack CHANGELOG
==================


0.0.1
-----
- @martinb3 - Add 'expanded' default that converges separate redis instances instead of a single one. This should now handle any configuration of runlist thrown at it.
- @martinb3 - Add tags to node before saving node, so tags are findable on node.save
- @martinb3 - Have utility library call node.save so we don't need 2 converges to find ourselves on a search
- @martinb3 - Add redisio as a direct dependency, and in Berksfile until release. redis-multi is too simplistic for this deployment, and some bugs are fixed in git that aren't released yet.
- @martinb3 - Add a redis discovery recipe that finds any redis instances in the same chef environment
- @martinb3 - Modify redis_single recipe to no longer rely on redis-multi
- @martinb3 - Add separate redis recipes for session store and page, object caches
- @martinb3 - Add redis sentinel recipe that filters discovered instances to find the right instance
- @martinb3 - Add expanded default recipe, that converges individual components (like 3 redis vs. single redis)
- @martinb3 - Add library with functions to search by node name and handle redisio attribute data
- @martinb3 - Add Apache vhost, cleanup testing for things we didn't converge
- @martinb3 - Remove return on missing attribute
- @martinb3 - Could not pass testing with listen_ports mixing node.default and node.set
- @martinb3 - Remove template for magentostack.ini, since actual source file was already removed
- @martinb3 - Switch to node.deep_fetch with additional guards, since some of the attributes were removed here
- @martinb3 - s/phpstack/magentostack/g everywhere
