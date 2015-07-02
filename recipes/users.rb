#
# Cookbook Name:: magentostack
# Recipe :: users
#
# Copyright 2015, Rackspace
#

return if node['magentostack']['users'] == false || node['magentostack']['users'] == 'false'

begin
  node.default['authorization']['sudo']['include_sudoers_d'] = true
  include_recipe 'sudo'

  users = data_bag_item('users', 'users')

  groups = {}

  all_users = users.to_hash.select { |k, v| k != 'id' } # strip out the id of the bag

  # only manage the subset of users defined
  Array(all_users.keys).each do |id|
    u = all_users[id]
    username = u['username'] || u['id'] || id
    user_action = Array(u['action']).map(&:to_sym) if u['action']

    user_account username do
      %w(comment uid gid home shell password system_user manage_home create_group
         ssh_keys ssh_keygen non_unique).each do |attr|
        send(attr, u[attr]) if u[attr]
      end
      shell '/usr/sbin/nologin' unless u['shell']
      action user_action
    end

    sudo username do
      user username
      nopasswd true
      only_if { u['sudo'] && u['sudo'] != 'false' }
    end

    # stop here if the groups are empty or we're removing this user
    next if u['groups'].nil? || user_action == 'remove'

    u['groups'].each do |groupname|
      groups[groupname] = [] unless groups[groupname]
      groups[groupname] += [username]
    end
  end

  groups.each do |groupname, membership|
    group groupname do
      members membership
      append true
    end
  end
rescue
  Chef::Log.warn('Failed to retrieve user data from data bags')
end
