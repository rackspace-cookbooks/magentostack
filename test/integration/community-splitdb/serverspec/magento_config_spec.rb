require 'spec_helper'

# check for split db configuration in local.xml
describe 'Magentostack xml configuration' do
  describe 'should show split reads and writes' do
    describe file('/var/www/html/magento/app/etc/local.xml') do
      split_expected = [
        /<core_write>/,
        /<core_read>/,
        %r{<use/>}
      ]

      split_expected.each do |r|
        its(:content) { should match(r) }
      end
      its(:content) { should_not match(/<default_setup>/) }
    end
  end
end
