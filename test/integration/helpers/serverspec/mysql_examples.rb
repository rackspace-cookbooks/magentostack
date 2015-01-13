
shared_examples_for 'magento under mysql' do |args|
  # mysql base
  if os[:family] == 'redhat'
    describe service('mysqld') do
      it { should be_enabled }
      it { should be_running }
    end
  else
    describe service('mysql') do
      it { should be_enabled }
      it { should be_running }
    end
  end
  describe port(3306) do
    it { should be_listening }
  end
  describe command('mysqld -V') do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should match(/5.6/) }
  end
end
