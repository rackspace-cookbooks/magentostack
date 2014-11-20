# Encoding: utf-8

require_relative 'spec_helper'

## redis single

# redis itself
describe service('redis6379-single-master') do
  it { should be_enabled }
end
describe port(6379) do
  it { should be_listening }
end


# sentinel for single
describe service('redis_sentinel_46379-sentinel') do
  it { should be_enabled }
end
describe port(46379) do
  it { should be_listening }
end
