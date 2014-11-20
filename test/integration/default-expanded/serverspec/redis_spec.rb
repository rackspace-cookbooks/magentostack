# Encoding: utf-8

require_relative 'spec_helper'

## redis expanded (separate instances)

describe service('redis6381-session-master') do
  it { should be_enabled }
end
describe port(6381) do
  it { should be_listening }
end

describe service('redis6383-object-master') do
  it { should be_enabled }
end
describe port(6383) do
  it { should be_listening }
end

describe service('redis6385-page-master') do
  it { should be_enabled }
end
describe port(6385) do
  it { should be_listening }
end

# sentinel for single
describe service('redis_sentinel_46379-sentinel') do
  it { should be_enabled }
end
describe port(46379) do
  it { should be_listening }
end
