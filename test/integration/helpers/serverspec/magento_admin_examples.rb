shared_examples_for 'magento admin' do |args|
  describe cron do
    it { should have_entry('*/5 * * * * /var/www/html/magento/cron.sh').with_user('apache') }
  end
end
