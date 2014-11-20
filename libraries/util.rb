# DRY module. Repeating yourself? Put it in a library!
#  Be wary of the node variable here. Prefer to pass node in and out of your
#  methods to allow wrappers to override node values and have them take effect
#  within this library.
module MagentostackUtil

  # Recompute node['redisio']['servers'] based on our node['magentostack']['redis']['servers']
  #  This is needed because the redisio node attribute is an array, and we'd rather not search
  #  the array for duplicates every time we want to configure an instance.
  def self.recompute_redis(current_node, key_name = 'servers')
    return unless key_name && current_node['magentostack']['redis'][key_name]

    redis_instances = []
    current_node['magentostack']['redis'][key_name].each do |key, value|
      redis_instances.push(value)
    end
    current_node.set['redisio'][key_name] = redis_instances

    # we must save so that search works during the same chef run
    # or a sentinel will require 2 runs to converge
    current_node.save unless Chef::Config[:solo]
    redis_instances
  end

  def self.get_ip_by_name(node_name, current_node)
    results = []
    Chef::Search::Query.new.search(:node, "name:#{node_name}") { |o| results << o }

    if results.count < 1
      found = nil
    else
      found = Chef::Sugar::IP::best_ip_for(current_node, results.first)
    end

    found
  end

end
