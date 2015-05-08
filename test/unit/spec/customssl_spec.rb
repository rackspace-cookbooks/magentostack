# Encoding: utf-8

require_relative 'spec_helper'

describe 'magentostack::apache-fpm' do
  before { stub_resources }
  supported_platforms.each do |platform, versions|
    versions.each do |version|
      context "on #{platform.capitalize} #{version}" do
        cached(:chef_run) do
          ChefSpec::SoloRunner.new(platform: platform, version: version, log_level: :fatal) do |node|
            node_resources(node) # stub this node

            # Stub the node and any calls to Environment.Load to return this environment
            env = Chef::Environment.new
            env.name 'chefspec' # matches ./test/integration/
            allow(node).to receive(:chef_environment).and_return(env.name)
            allow(Chef::Environment).to receive(:load).and_return(env)

            # no ssl specific stuff
            node.set['magentostack']['web']['ssl_custom'] = true
          end.converge(described_recipe) # *splat operator for array to vararg
        end

        property = load_platform_properties(platform: platform, platform_version: version)
        property.to_s # pacify rubocop

        it 'should include apache2::mod_ssl' do
          expect(chef_run).to include_recipe('apache2::mod_ssl')
        end

        it 'does enable ssl module' do
          expect(chef_run).to run_execute('a2enmod ssl')
        end

        it 'should copy the ssl certificate out of an encrypted data bag' do
          expect(chef_run).to create_certificate_manage('magento ssl certificate')
            .with(
              cert_path: '/etc/pki/tls',
              cert_file: 'fauxhai.local.pem',
              key_file: 'fauxhai.local.key',
              chain_file: 'Fauxhai-bundle.crt'
            )
        end

        it 'should render a virtualhost configuration including the custom ssl' do
          ssl_lines = [
            /SSLEngine on/,
            %r{SSLCertificateFile /etc/pki/tls/certs/.*.pem},
            %r{SSLCertificateKeyFile /etc/pki/tls/private/.*.key}
          ]

          ssl_lines.each do |line|
            expect(chef_run).to render_file('/etc/httpd/sites-available/magento_ssl_vhost.conf')
              .with_content(line)
          end
        end
      end
    end
  end
end
