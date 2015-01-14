# Encoding: utf-8
#
# Cookbook Name:: magentostack
# Recipe:: mysql_logging
#
# Copyright 2014, Rackspace Hosting
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# required because we set the log in a mysql dir
directory '/var/log/mysql' do
  user 'mysql'
  action :create
end
logrotate_app 'mysql_slow_log' do
  path      '/var/log/mysql/slow.log'
  create   '644 mysql mysql'
  options   ['notifempty', 'missingok', 'compress']
  frequency 'daily'
  rotate    5
  postrotate <<-EOF
    # just if mysqld is really running
    if test -x /usr/bin/mysqladmin && /usr/bin/mysqladmin ping &>/dev/null
    then
       /usr/bin/mysqladmin flush-logs
    fi
  EOF
end
