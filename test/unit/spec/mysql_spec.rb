require_relative 'spec_helper'

describe 'magentostack::mysql' do
  before { stub_resources }
  supported_platforms.each do |platform, versions|
    versions.each do |version|
      context "on #{platform.capitalize} #{version}" do
        shared_examples_for 'mysql logrotation' do
          it 'configures log rotation for Mysql slow queries' do
            logrotate = [
              '/var/log/mysql/slow.log',
              'notifempty',
              'daily',
              'rotate 5',
              'missingok',
              'compress',
              'postrotate',
              'mysqladmin ping',
              'mysqladmin flush-logs',
              'endscript'
            ]
            logrotate.each do |line|
              expect(chef_run).to render_file('/etc/logrotate.d/mysql_slow_log').with_content(line)
            end
          end
        end
        shared_examples_for 'mysql configuration' do
          it 'configures mysql with team recommendations' do
            mysql_conf = [
              'tmpdir = /dev/shm',
              'table_definition_cache = 4096',
              'table_open_cache = 4096',
              'query_cache_size = 64M',
              'query_cache_type = 1',
              'query_cache_limit = 2M',
              'join_buffer_size = 2M',
              'read_buffer_size = 2M',
              'read_rnd_buffer_size = 8M',
              'sort_buffer_size = 2M',
              'max_heap_table_size = 96M',
              'tmp_table_size = 96M',
              'max_connections = 500',
              'max_user_connections = 400',
              'max_connect_errors = 1000000',
              'max_allowed_packet = 256M',
              'slave_net_timeout = 60',
              'skip_name_resolve',
              'wait_timeout = 600',
              'key_buffer_size = 32M',
              'myisam_sort_buffer_size = 256M',
              'innodb_buffer_pool_size = 512M',
              'innodb_file_per_table',
              'innodb_log_file_size = 100M',
              'innodb_purge_threads = 4',
              'innodb_thread_concurrency = 32',
              'innodb_lock_wait_timeout = 300',
              'expire_logs_days = 5',
              'max_binlog_size = 128M',
              'relay_log_space_limit = 16G',
              'server_id = 1',
              'log_output = FILE',
              'log_slow_admin_statements',
              'log_slow_slave_statements',
              'long_query_time = 2',
              'slow_query_log = 1',
              'slow_query_log_file = /var/log/mysql/slow.log',
              '[mysqld_safe]',
              'log_error = /var/log/mysql/mysqld.log',
              'open_files_limit = 65535',
              'no_auto_rehash'
            ]
            mysql_conf.each do |line|
              expect(chef_run).to render_file('/etc/mysql/conf.d/my.cnf').with_content(line)
            end
          end
        end
        context 'for mysql_master' do
          cached(:chef_run) do
            ChefSpec::ServerRunner.new(platform: platform, version: version, log_level: ::LOG_LEVEL) do |node, server|
              node_resources(node)
            end.converge('magentostack::mysql_master')
          end

          it 'includes stack_commons recipe' do
            expect(chef_run).to include_recipe('stack_commons::mysql_master')
          end
          it 'creates mysq log directory' do
            expect(chef_run).to create_directory('/var/log/mysql')
          end
          it_should_behave_like 'mysql logrotation'
          it_should_behave_like 'mysql configuration'
        end

        context 'for mysql_slave' do
          cached(:chef_run) do
            ChefSpec::ServerRunner.new(platform: platform, version: version, log_level: ::LOG_LEVEL) do |node, server|
              stub_nodes(platform, version, server)
              node_resources(node)
            end.converge('magentostack::mysql_slave')
          end

          it 'includes stack_commons recipe' do
            expect(chef_run).to include_recipe('stack_commons::mysql_slave')
          end
          it_should_behave_like 'mysql logrotation'
          it_should_behave_like 'mysql configuration'
        end

        context 'for mysql_holland' do
          cached(:chef_run) do
            ChefSpec::ServerRunner.new(platform: platform, version: version, log_level: ::LOG_LEVEL) do |node, server|
              node_resources(node)
            end.converge('magentostack::mysql_holland')
          end

          it 'includes stack_commons recipe' do
            expect(chef_run).to include_recipe('stack_commons::mysql_holland')
          end
        end

        context 'for mysql_add_drive' do
          cached(:chef_run) do
            ChefSpec::ServerRunner.new(platform: platform, version: version, log_level: ::LOG_LEVEL) do |node, server|
              node_resources(node)
            end.converge('magentostack::mysql_add_drive')
          end

          it 'includes stack_commons recipe' do
            expect(chef_run).to include_recipe('stack_commons::mysql_add_drive')
          end
        end
      end
    end
  end
end
