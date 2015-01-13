# Encoding: utf-8

require 'spec_helper'

describe 'Magento web' do
  it 'can connect to magento' do
    expect(page_returns('https://localhost:8443/', 'localhost', true)).to match(/You have no items in your shopping cart./)
  end
end
