# Encoding: utf-8
require 'serverspec'
require 'net/http'
require 'openssl'

require_relative 'default_examples'
require_relative 'cache_examples'
require_relative 'apache_examples'
require_relative 'php_examples'
require_relative 'mysql_examples'
require_relative 'magento_admin_examples'

set :backend, :exec
set :path, '/sbin:/usr/local/sbin:/bin:/usr/bin:$PATH'

def redhat_family_values
  res = {}
  res['docroot'] = '/var/www/html/magento'
  res['apache_service_name'] = 'httpd'
  res['fpm_service_name'] = 'php-fpm'
  res['apache2ctl'] = '/usr/sbin/apachectl'
  res
end

def debian_family_values
  res = {}
  res['docroot'] = '/var/www/magento'
  res['apache_service_name'] = 'apache2'
  res['fpm_service_name'] = 'php5-fpm'
  res['apache2ctl'] = '/usr/sbin/apache2ctl'
  res
end

def family_value(str)
  if os[:family] == 'redhat'
    redhat_family_values[str]
  else
    debian_family_values[str]
  end
end

def docroot
  family_value('docroot')
end

def apache_service_name
  family_value('apache_service_name')
end

def fpm_service_name
  family_value('fpm_service_name')
end

def apache2ctl
  family_value('apache2ctl')
end

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
