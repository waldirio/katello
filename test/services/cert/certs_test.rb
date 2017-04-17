require 'katello_test_helper'
require 'support/candlepin/owner_support'

module Katello
  class CertsTest < ActiveSupport::TestCase
    def setup
      VCR.insert_cassette('lib/tasks/verify_ueber_cert')
      @org = get_organization
      Resources::Candlepin::Owner.create(@org.label, @org.name)
    end

    def teardown
      Resources::Candlepin::Owner.destroy(@org.label)
      VCR.eject_cassette
    end

    def test_verify_ueber_cert
      Setting.stubs(:[]).with(:ssl_ca_file).returns("/home/vagrant/foreman/test/services/cert/helpers/ca.crt")
      cert_valid = Cert::Certs.verify_ueber_cert(@org) 
      assert cert_valid
    end
  end
end
