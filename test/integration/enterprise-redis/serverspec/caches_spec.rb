require 'spec_helper'

# object cache (magento calls this the 'cache', in redis db 0)
# page cache (EE only, in redis db 1)
# session cache (magento calls this the 'cache', in redis db 2)
describe 'enterprise with separate redis instances for object, page, and session cache' do
  before do
    clear_out_redis '-a runstatepasswordobject -p 6383 -n 0'
    clear_out_redis '-a runstatepasswordpage -p 6385 -n 1'
    clear_out_redis '-a runstatepasswordsession -p 6381 -n 2'
    flush_all_magento_caches
    page_returns
  end
  it_behaves_like 'magento redis cache', '-p 6383 -a runstatepasswordobject -n 0'
  it_behaves_like 'magento redis cache', '-p 6385 -a runstatepasswordpage -n 1'
  it_behaves_like 'magento redis cache', '-p 6381 -a runstatepasswordsession -n 2'
end
