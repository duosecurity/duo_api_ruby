# frozen_string_literal: true

require_relative 'common'

##
# DuoApi::Accounts tests
#
class TestAccounts < HTTPTestCase
  setup
  def setup_test_globals
    @accounts_api = DuoApi::Accounts.new(IKEY, SKEY, HOST)
  end

  def test_get_child_accounts
    @mock_http.expects(:request).returns(@json_ok_str_resp)
    assert_nothing_raised{ @accounts_api.get_child_accounts }
  end

  def test_create_child_account
    @mock_http.expects(:request).returns(@json_ok_str_resp)
    required_args = { name: 'NAME' }
    assert_nothing_raised{ @accounts_api.create_child_account(**required_args) }
  end

  def test_create_child_account_args_missing
    @mock_http.expects(:request).times(0)
    required_args = [:name]
    assert_raise_with_message(
      ArgumentError,
      missing_keywords_message(required_args)
    ){ @accounts_api.create_child_account }
  end

  def test_delete_child_account
    @mock_http.expects(:request).returns(@json_ok_str_resp)
    required_args = { account_id: 'ACCOUNTID' }
    assert_nothing_raised{ @accounts_api.delete_child_account(**required_args) }
  end

  def test_delete_child_account_args_missing
    @mock_http.expects(:request).times(0)
    required_args = [:account_id]
    assert_raise_with_message(
      ArgumentError,
      missing_keywords_message(required_args)
    ){ @accounts_api.delete_child_account }
  end
end

##
# DuoApi::Accounts.admin_api tests
#
class TestAccountsAdminApi < HTTPTestCase
  setup
  def setup_test_globals
    @accounts_api = DuoApi::Accounts.new(IKEY, SKEY, HOST)

    @child_account_id_good = 'DAGOODCHILDACCOUNTID'
    @child_account_id_bad = 'DABADCHILDACCOUNTID'
    @child_account_json_ok = Net::HTTPSuccess.new(
      '200',
      {
        stat: 'OK',
        response: [{
          account_id: @child_account_id_good,
          api_hostname: HOST,
          name: 'Child Account 1'
        }]
      },
      { 'Content-Type': 'application/json' }
    )
  end

  def test_admin_api
    @mock_http.expects(:request).returns(@child_account_json_ok)
    required_args = { child_account_id: @child_account_id_good }
    assert_instance_of(DuoApi::Admin, @accounts_api.admin_api(**required_args))
  end

  def test_admin_api_args_missing
    @mock_http.expects(:request).times(0)
    required_args = [:child_account_id]
    assert_raise_with_message(
      ArgumentError,
      missing_keywords_message(required_args)
    ){ @accounts_api.admin_api }
  end

  def test_admin_api_bad_child_account
    @mock_http.expects(:request).returns(@child_account_json_ok)
    assert_raise_with_message(
      DuoApi::ChildAccountError,
      "Child account #{@child_account_id_bad} not found"
    ){ @accounts_api.admin_api(child_account_id: @child_account_id_bad) }
  end

  def test_admin_api_get_edition
    @mock_http.expects(:request).twice.returns(@child_account_json_ok, @json_ok_str_resp)
    accounts_admin_api = @accounts_api.admin_api(child_account_id: @child_account_id_good)
    assert_nothing_raised{ accounts_admin_api.get_edition }
  end

  def test_admin_api_set_edition
    @mock_http.expects(:request).twice.returns(@child_account_json_ok, @json_ok_str_resp)
    accounts_admin_api = @accounts_api.admin_api(child_account_id: @child_account_id_good)
    required_args = { edition: 'BEYOND' }
    assert_nothing_raised{ accounts_admin_api.set_edition(**required_args) }
  end

  def test_admin_api_set_edition_args_missing
    @mock_http.expects(:request).returns(@child_account_json_ok)
    accounts_admin_api = @accounts_api.admin_api(child_account_id: @child_account_id_good)
    required_args = [:edition]
    assert_raise_with_message(
      ArgumentError,
      missing_keywords_message(required_args)
    ){ accounts_admin_api.set_edition }
  end

  def test_admin_api_get_telephony_credits
    @mock_http.expects(:request).twice.returns(@child_account_json_ok, @json_ok_str_resp)
    accounts_admin_api = @accounts_api.admin_api(child_account_id: @child_account_id_good)
    assert_nothing_raised{ accounts_admin_api.get_telephony_credits }
  end

  def test_admin_api_set_telephony_credits
    @mock_http.expects(:request).twice.returns(@child_account_json_ok, @json_ok_str_resp)
    accounts_admin_api = @accounts_api.admin_api(child_account_id: @child_account_id_good)
    required_args = { credits: 100 }
    assert_nothing_raised{ accounts_admin_api.set_telephony_credits(**required_args) }
  end

  def test_admin_api_set_telephony_credits_args_missing
    @mock_http.expects(:request).returns(@child_account_json_ok)
    accounts_admin_api = @accounts_api.admin_api(child_account_id: @child_account_id_good)
    required_args = [:credits]
    assert_raise_with_message(
      ArgumentError,
      missing_keywords_message(required_args)
    ){ accounts_admin_api.set_telephony_credits }
  end
end
