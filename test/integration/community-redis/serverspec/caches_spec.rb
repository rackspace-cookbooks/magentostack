require 'spec_helper'

# object cache (magento calls this the 'cache', in redis db 0)
# session cache (magento calls this the 'cache', in redis db 2)
describe 'community with separate redis' do
  before do
    clear_out_redis '-a runstatepasswordobject -n 0'
    clear_out_redis '-a runstatepasswordsession -n 2'
    flush_all_magento_caches
    page_returns
  end
  it_behaves_like 'magento redis cache', '-p 6383 -a runstatepasswordobject -n 0'
  it_behaves_like 'magento redis cache', '-p 6381 -a runstatepasswordsession -n 2'
end
