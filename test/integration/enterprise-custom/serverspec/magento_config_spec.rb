require 'spec_helper'

describe 'Magentostack xml configuration' do
  describe 'Redis password for session' do
    describe file('/var/www/html/magento/app/etc/local.xml') do
      its(:content) { should match %r{<password>runstatepasswordsession</password>} }
    end
  end
  describe 'Redis password for object' do
    describe file('/var/www/html/magento/app/etc/local.xml') do
      its(:content) { should match %r{<password>runstatepasswordobject</password>} }
    end
  end
  describe 'Redis password for full page' do
    describe file('/var/www/html/magento/app/etc/local.xml') do
      its(:content) { should match %r{<password>runstatepasswordpage</password>} }
    end
  end
end

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
