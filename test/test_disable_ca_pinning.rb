# frozen_string_literal: true

require_relative 'common'

class TestDisableCaPinning < Test::Unit::TestCase
  def test_default_has_ca_pinning_enabled
    client = DuoApi.new(IKEY, SKEY, HOST)
    assert_equal(false, client.ca_pinning_disabled)
    assert_not_nil(client.ca_file)
    assert(File.exist?(client.ca_file))
  end

  def test_disable_ca_pinning_removes_ca_file
    client = DuoApi.new(IKEY, SKEY, HOST, nil, disable_ca_pinning: true)
    assert_equal(true, client.ca_pinning_disabled)
    assert_nil(client.ca_file)
  end

  def test_disable_ca_pinning_and_custom_ca_file_raises
    assert_raise(ArgumentError) do
      DuoApi.new(IKEY, SKEY, HOST, nil, ca_file: '/some/cert.pem', disable_ca_pinning: true)
    end
  end

  def test_disable_ca_pinning_and_custom_ca_file_error_message
    error = assert_raise(ArgumentError) do
      DuoApi.new(IKEY, SKEY, HOST, nil, ca_file: '/some/cert.pem', disable_ca_pinning: true)
    end
    assert_equal('Cannot both disable CA pinning and provide a custom CA file', error.message)
  end

  def test_custom_ca_file_without_disable_works
    client = DuoApi.new(IKEY, SKEY, HOST, nil, ca_file: '/some/cert.pem')
    assert_equal(false, client.ca_pinning_disabled)
    assert_equal('/some/cert.pem', client.ca_file)
  end
end

class TestDisableCaPinningHTTP < BaseTestCase
  def setup
    @client_pinned = DuoApi.new(IKEY, SKEY, HOST)
    @client_unpinned = DuoApi.new(IKEY, SKEY, HOST, nil, disable_ca_pinning: true)
    @mock_http = mock
    @ok_resp = Net::HTTPSuccess.new('200')
  end

  def test_pinned_client_passes_ca_file_to_http
    ca_file = @client_pinned.ca_file
    Net::HTTP.expects(:start).with do |_host, _port, **opts|
      opts[:use_ssl] == true &&
        opts[:verify_mode] == OpenSSL::SSL::VERIFY_PEER &&
        opts[:ca_file] == ca_file
    end.yields(@mock_http)
    @mock_http.expects(:request).returns(@ok_resp)
    @client_pinned.request('GET', '/foo/bar')
  end

  def test_unpinned_client_does_not_pass_ca_file_to_http
    Net::HTTP.expects(:start).with do |_host, _port, **opts|
      opts[:use_ssl] == true &&
        opts[:verify_mode] == OpenSSL::SSL::VERIFY_PEER &&
        !opts.key?(:ca_file)
    end.yields(@mock_http)
    @mock_http.expects(:request).returns(@ok_resp)
    @client_unpinned.request('GET', '/foo/bar')
  end
end
