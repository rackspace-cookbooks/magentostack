# Encoding: utf-8

require_relative 'spec_helper'

describe 'Magento web' do
  it 'can connect to magento' do
    expect(page_returns('https://localhost:443/', 'localhost', true)).to match(/You have no items in your shopping cart./)
  end
end
# describe command("#{redis_path}/redis-cli -p 46379 SENTINEL masters") do
#  its(:stdout) { should match(/port\n6379/) }
# end
