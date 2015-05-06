# spec/support/matchers.rb
def create_rackspacecloud_file(resource_name)
  ChefSpec::Matchers::ResourceMatcher.new(:rackspacecloud_file, :create, resource_name)
end

def put_ark(resource_name)
  ChefSpec::Matchers::ResourceMatcher.new(:ark, :put, resource_name)
end

def openssl_x509(resource_name)
  ChefSpec::Matchers::ResourceMatcher.new(:openssl_x509, :create, resource_name)
end
