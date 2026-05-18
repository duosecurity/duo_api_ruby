# frozen_string_literal: true

require_relative 'common'

##
# DuoApi::Authorization tests
#
class TestAuthorization < HTTPTestCase
  setup
  def setup_test_globals
    @authz_api = DuoApi::Authorization.new(IKEY, SKEY, HOST)
  end

  def test_ping
    @mock_http.expects(:request).returns(@json_ok_str_resp)
    assert_nothing_raised{ @authz_api.ping }
  end

  def test_check
    @mock_http.expects(:request).returns(@json_ok_str_resp)
    assert_nothing_raised{ @authz_api.check }
  end

  def test_evaluate
    response_body = {
      stat: 'OK',
      response: {
        allowed_capabilities: ['tool_call'],
        authorized: true,
        expires_at: 1_700_000_000,
        user_id: 'DUSR000000000000001',
        non_human_identity: 'agent_123',
        policy_version_id: 42
      }
    }
    mock_resp = Net::HTTPSuccess.new('200', response_body, { 'Content-Type': 'application/json' })
    @mock_http.expects(:request).returns(mock_resp)

    capabilities = DuoApi::Authorization::McpCapabilities.new(
      access_token: 'test_token',
      mcp_server_id: 'server_123'
    )
    result = @authz_api.evaluate(capabilities)

    assert_equal ['tool_call'], result[:allowed_capabilities]
    assert_equal true, result[:authorized]
    assert_equal 1_700_000_000, result[:expires_at]
    assert_equal 'DUSR000000000000001', result[:user_id]
    assert_equal 'agent_123', result[:non_human_identity]
    assert_equal 42, result[:policy_version_id]
  end

  def test_evaluate_with_optional_params
    response_body = {
      stat: 'OK',
      response: {
        allowed_capabilities: nil,
        authorized: true,
        expires_at: 1_700_000_000,
        user_id: 'DUSR000000000000001',
        non_human_identity: 'agent_123',
        policy_version_id: nil
      }
    }
    mock_resp = Net::HTTPSuccess.new('200', response_body, { 'Content-Type': 'application/json' })
    @mock_http.expects(:request).returns(mock_resp)

    capabilities = DuoApi::Authorization::McpCapabilities.new(
      access_token: 'test_token',
      mcp_server_id: 'server_123',
      mcp_server_name: 'my_server',
      tool: 'my_tool'
    )
    assert_nothing_raised{ @authz_api.evaluate(capabilities) }
  end

  def test_evaluate_missing_required_args
    @mock_http.expects(:request).times(0)
    assert_raise(ArgumentError) do
      DuoApi::Authorization::McpCapabilities.new
    end
  end
end
