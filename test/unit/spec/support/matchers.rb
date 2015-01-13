# spec/support/matchers.rb
def create_rackspacecloud_file(resource_name)
  ChefSpec::Matchers::ResourceMatcher.new(:rackspacecloud_file, :create, resource_name)
end
