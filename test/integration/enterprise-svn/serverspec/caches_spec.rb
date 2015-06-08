require 'spec_helper'

# object cache (magento calls this the 'cache', in redis db 0)
# page cache (EE only, in redis db 1)
# session cache (magento calls this the 'cache', in redis db 2)
describe 'enterprise-git with single redis instance' do
  before do
    clear_out_redis '-a runstatepasswordsingle -n 0'
    clear_out_redis '-a runstatepasswordsingle -n 1'
    clear_out_redis '-a runstatepasswordsingle -n 2'
    flush_all_magento_caches
    page_returns
  end
  it_behaves_like 'magento redis cache', '-a runstatepasswordsingle -n 0'
  it_behaves_like 'magento redis cache', '-a runstatepasswordsingle -n 1'
  it_behaves_like 'magento redis cache', '-a runstatepasswordsingle -n 2'
end
