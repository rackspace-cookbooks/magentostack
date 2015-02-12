require 'spec_helper'

describe port(8080) do
  it { should be_listening }
end
describe port(8443) do
  it { should be_listening }
end

# be sure the cert from our encrypted data bag matches what we're seeing on localhost:8443
describe command('openssl s_client -showcerts -connect localhost:8443 </dev/null | openssl x509 | openssl md5') do
  its(:stdout) { should match(/fe5fe144211811c527b0c82c9c34069a/) }
end

describe command('md5sum /etc/pki/tls/certs/test-bundle.crt') do
  its(:stdout) { should match(/cf7c4dfcb22e666880a9291ad5f60502/) }
end

describe command('md5sum /etc/pki/tls/certs/test.pem') do
  its(:stdout) { should match(/d828d93f5a98bfca4bf6f4d944a57e13/) }
end

describe command('md5sum /etc/pki/tls/private/test.key') do
  its(:stdout) { should match(/03a868662bb7e303d2d97599daac7dfa/) }
end
