# DRY module. Repeating yourself? Put it in a library!
#  Be wary of the node variable here. Prefer to pass node in and out of your
#  methods to allow wrappers to override node values and have them take effect
#  within this library.
# rubocop:disable Metrics/AbcSize, Metrics/PerceivedComplexity
module MagentostackUtil
  # Discover redis instances and apply filter_proc for locating a single instance
  #  While this is called find_masters, it technically could be used on any
  #  search terms. It is master-specific in the data it returns about a particular
  #  redis instance (just what the master needs to connect)
  def self.redis_find_masters(current_node, &filter_proc)
    # find redis instances in the same chef environment
    found_instances = MagentostackUtil.redis_discovery(current_node)
    if found_instances && !found_instances.empty?
      Chef::Log.debug("Master disco found the following instances: #{found_instances.keys.join(',')}")
    else
      Chef::Log.warn('Master disco not find any redis instances')
      return
    end

    master_name, master_ip, master_port = nil, nil, nil

    # look for a master instance using the supplied filter
    masters = found_instances.select(&filter_proc)
    if masters && !masters.empty?
      if masters.count > 1
        Chef::Log.warn("Master disco found more than one redis instance: #{masters.keys.join(',')}")
      else
        Chef::Log.debug("Master disco found #{masters.count} masters: #{masters.keys.join(',')}")
      end
      master_name, master_data = masters.first
      master_ip = MagentostackUtil.get_ip_by_name(master_name, current_node)
      master_port = master_data['port']
    end

    if master_name && master_ip && master_port
      Chef::Log.info("Master disco chose #{master_name} (#{master_ip}:#{master_port}) ")
    else
      Chef::Log.warn('Master disco did not find any instances, not proceeding')
    end

    return master_name, master_ip, master_port
  end

  # Find all redis instances in the scope of the cookbook (see query below).
  #  The sentinel or slave recipes will use this data to figure out where the
  #  masters are (sentinel) or replicate from (slaves).
  #
  #  By default, it tries to just use the preset node['magentostack']['redis']['discovery'].
  #  If that preset isn't available, under chef solo, it warns and finishes.
  #  Otherwise, it does a search using node['magentostack']['redis']['discovery_query'].
  def self.redis_discovery(current_node)
    # see if the configuration specified some hard coded values
    preset_nodes = current_node.deep_fetch('magentostack', 'redis', 'discovery')

    # use preset if it exists
    if preset_nodes
      Chef::Log.info("Redis server discovery was already set to #{preset_nodes}")
      return preset_nodes
    end

    # if solo, just warn
    if Chef::Config[:solo]
      Chef::Log.warn('redis_cache_find recipe uses search if node[\'magentostack\'][\'redis\'][\'discovery\']  attribute is not set.')
      Chef::Log.warn('Chef Solo does not support search.')
      return {}
    end

    # otherwise, do the search we want to discover other redis nodes
    discovered_nodes = {}
    redis_nodes = []
    query = current_node['magentostack']['redis']['discovery_query']
    Chef::Search::Query.new.search('node', query) { |o| redis_nodes << o }

    if redis_nodes.nil? || redis_nodes.count < 1
      errmsg = 'Did not find any redis nodes in discovery, but none were set'
      Chef::Log.warn(errmsg)
      redis_nodes = [] # so loop below exits
    end

    redis_nodes.each do |n|
      # n may not be a Chef::Node so we can't use node#deep_fetch from chef/sugar
      if n['magentostack'] && n['magentostack']['redis'] && n['magentostack']['redis']['servers']
        n['magentostack']['redis']['servers'].each do |redis_name, redis_instance|
          discovered_nodes[redis_name] = redis_instance
          Chef::Log.debug("Discovery found redis instance #{redis_name}:#{redis_instance}")
        end
      else
        Chef::Log.warn("Found node #{n.name} but didn't see any data under its ['magentostack']['redis']['servers'] attribute")
      end
    end

    return discovered_nodes
  end

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

  # Given a node name, look up the IP for that node based on the current node.
  #  This is here because best_ip_for(node) doesn't normally take strings, it needs
  #  a real node object so it can find the IPs on the node's attribute data. I
  #  wanted something that accepted a string for the redis discovery.
  def self.get_ip_by_name(node_name, current_node)
    results = []
    Chef::Search::Query.new.search(:node, "name:#{node_name}") { |o| results << o }

    if results.count < 1
      found = nil
    else
      found = Chef::Sugar::IP.best_ip_for(current_node, results.first)
    end

    found
  end
end
# rubocop:enable Metrics/AbcSize, Metrics/PerceivedComplexity
