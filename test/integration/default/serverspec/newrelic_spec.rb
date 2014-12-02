# Encoding: utf-8

require_relative 'spec_helper'

describe service('newrelic-plugin-agent') do
  it { should be_enabled }
  it { should be_running }
end

describe service('newrelic-mysql-plugin') do
  it { should be_enabled }
end
