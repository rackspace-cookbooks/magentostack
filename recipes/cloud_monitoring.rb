#
# Cookbook Name:: magentostack
# Recipe :: cloud_monitoring
#
# Copyright 2015, Rackspace
#

include_recipe 'chef-sugar-rackspace'

begin
  cloud_credentials = data_bag_item('rackspace', 'cloud_credentials')
  cloud_username = cloud_credentials['username']
  cloud_api_key = cloud_credentials['api_key']
rescue
  Chef::Log.warn('Problem finding cloud credentials in databag item rackspace:cloud_credentials')
end

begin
  cloud_username = MagentostackUtil.get_runstate_or_attr(node, 'rackspace_cloud_monitoring', 'cloud_credentials_username')
  cloud_api_key = MagentostackUtil.get_runstate_or_attr(node, 'rackspace_cloud_monitoring', 'cloud_credentials_api_key')
rescue
  Chef::Log.warn('Problem finding cloud credentials in run state or node attributes')
end

unless cloud_username && cloud_api_key
  Chef::Log.warn('Unable to locate valid cloud credentials using any method')
  return
end

rackspace_cloud_monitoring_service 'default' do
  cloud_credentials_username cloud_username
  cloud_credentials_api_key cloud_api_key
  action [:create, :start]
end

rackspace_cloud_monitoring_check 'cpu' do
  type 'agent.cpu'
  alarm true
  action :create
end

rackspace_cloud_monitoring_check 'load' do
  type 'agent.load'
  alarm true
  action :create
end

rackspace_cloud_monitoring_check 'memory' do
  type 'agent.memory'
  alarm true
  action :create
end

ignored_fs_types = %w(cgroup configfs devpts devtmpfs
                      efivars fusectl mqueue proc pstore
                      securityfs sys sysfs tmpfs xenfs)

# node['filesystem'] does not exist in kitchen-docker or chefspec
if node['filesystem']
  node['filesystem'].each do |k, v|
    next if v['fs_type'].nil? ||
            v['percent_used'].nil? ||
            ignored_fs_types.include?(v['fs_type'])
    rackspace_cloud_monitoring_check k do
      type 'agent.filesystem'
      target v['mount']
      alarm true
      action :create
    end
  end
end
