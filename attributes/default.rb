# Encoding: utf-8
#
# Cookbook Name:: magentostack
# Recipe:: default
#
# Copyright 2014, Rackspace UK, Ltd.
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

stackname = 'magentostack'

# Stack_commons configuration attributes
# should not be changed
default['stack_commons']['stackname'] = stackname
default[stackname]['db-autocreate']['enabled'] = false
# Stack_commons attributes requirement
# should not be changed
default[stackname]['webserver'] = 'apache'
default[stackname]['apache']['sites'] = {}
default[stackname]['mysql']['databases'] = {}
default[stackname]['varnish']['backend_nodes'] = {}
default[stackname]['varnish']['multi'] = true

# Toggle newrelic application monitoring
default[stackname]['newrelic']['application_monitoring']['php']['enabled'] = 'false'
