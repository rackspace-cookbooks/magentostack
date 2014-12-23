# Encoding: utf-8
#
# Cookbook Name:: magentostack
# Recipe:: monitoring
#
# Copyright 2014, Rackspace Hosting
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# push to be sure we don't reset custom_monitors
default['platformstack']['cloud_monitoring']['custom_monitors']['name'].push('custom_http')
default['platformstack']['cloud_monitoring']['custom_monitors']['custom_http']['source'] = 'cloud-monitoring/monitoring-remote-http.yaml.erb'
default['platformstack']['cloud_monitoring']['custom_monitors']['custom_http']['cookbook'] = 'magentostack'
default['platformstack']['cloud_monitoring']['custom_monitors']['custom_http']['variables'] = {
  disabled: false,
  alarm: false,
  period: 60,
  timeout: 15
}
