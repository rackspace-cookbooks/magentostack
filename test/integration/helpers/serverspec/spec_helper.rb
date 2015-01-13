# Encoding: utf-8
require 'serverspec'
require 'net/http'
require 'openssl'

require_relative 'default_examples'

set :backend, :exec
set :path, '/sbin:/usr/local/sbin:/bin:/usr/bin:$PATH'

def page_returns(url = 'http://localhost:8080/', host = 'localhost', ssl = false)
  uri = URI.parse(url)
  http = Net::HTTP.new(uri.host, uri.port)
  http.read_timeout = 70
  if ssl
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  end
  req = Net::HTTP::Get.new(uri.request_uri)
  req.initialize_http_header('Host' => host)
  http.request(req).body
end

def clear_out_redis(args, redis_path = '/usr/local/bin')
  "#{redis_path}/redis-cli #{args} --no-raw flushdb"
end
