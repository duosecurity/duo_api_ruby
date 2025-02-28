# frozen_string_literal: true

require_relative 'common'

##
# DuoApi::Auth tests
#
class TestAuth < HTTPTestCase
  setup
  def setup_test_globals
    @auth_api = DuoApi::Auth.new(IKEY, SKEY, HOST)
  end

  def test_ping
    @mock_http.expects(:request).returns(@json_ok_str_resp)
    assert_nothing_raised{ @auth_api.ping }
  end

  def test_check
    @mock_http.expects(:request).returns(@json_ok_str_resp)
    assert_nothing_raised{ @auth_api.check }
  end

  def test_logo
    @mock_http.expects(:request).returns(@image_ok_resp)
    assert_nothing_raised{ @auth_api.logo }
  end

  def test_enroll
    @mock_http.expects(:request).returns(@json_ok_str_resp)
    assert_nothing_raised{ @auth_api.enroll }
  end

  def test_enroll_optional_args
    @mock_http.expects(:request).returns(@json_ok_str_resp)
    optional = { things: 'AND STUFF' }
    assert_nothing_raised{ @auth_api.enroll(**optional) }
  end

  def test_enroll_status
    @mock_http.expects(:request).returns(@json_ok_str_resp)
    required_args = { user_id: 'USERID', activation_code: 'CODE' }
    assert_nothing_raised{ @auth_api.enroll_status(**required_args) }
  end

  def test_enroll_status_args_missing
    @mock_http.expects(:request).times(0)
    required_args = %i[user_id activation_code]
    assert_raise_with_message(
      ArgumentError,
      missing_keywords_message(required_args)
    ){ @auth_api.enroll_status }
  end

  def test_preauth
    @mock_http.expects(:request).returns(@json_ok_str_resp)
    assert_nothing_raised{ @auth_api.preauth }
  end

  def test_preauth_optional_args
    @mock_http.expects(:request).returns(@json_ok_str_resp)
    optional = { things: 'AND STUFF' }
    assert_nothing_raised{ @auth_api.preauth(**optional) }
  end

  def test_auth
    @mock_http.expects(:request).returns(@json_ok_str_resp)
    required_args = { factor: 'auto' }
    assert_nothing_raised{ @auth_api.auth(**required_args) }
  end

  def test_auth_optional_args
    @mock_http.expects(:request).returns(@json_ok_str_resp)
    required_args = { factor: 'auto' }
    optional = { things: 'AND STUFF' }
    assert_nothing_raised{ @auth_api.auth(**required_args, **optional) }
  end

  def test_auth_args_missing
    @mock_http.expects(:request).times(0)
    required_args = [:factor]
    assert_raise_with_message(
      ArgumentError,
      missing_keywords_message(required_args)
    ){ @auth_api.auth }
  end

  def test_auth_status
    @mock_http.expects(:request).returns(@json_ok_str_resp)
    required_args = { txid: 'TXID' }
    assert_nothing_raised{ @auth_api.auth_status(**required_args) }
  end

  def test_auth_status_args_missing
    @mock_http.expects(:request).times(0)
    required_args = [:txid]
    assert_raise_with_message(
      ArgumentError,
      missing_keywords_message(required_args)
    ){ @auth_api.auth_status }
  end
end
