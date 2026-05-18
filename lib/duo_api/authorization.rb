# frozen_string_literal: true

require_relative 'api_client'
require_relative 'api_helpers'

class DuoApi
  ##
  # Duo Authorization API
  #
  class Authorization < DuoApi
    MCP_CAPABILITIES_ROUTE = 'mcp_capabilities'

    def ping
      get('/authorize/v1/ping')[:response]
    end

    def check
      get('/authorize/v1/check')[:response]
    end

    def evaluate(access_token:, mcp_server_id:, mcp_server_name: '', tool: nil)
      params = {
        access_token: access_token,
        mcp_server_id: mcp_server_id,
        mcp_server_name: mcp_server_name
      }
      params[:tool] = tool unless tool.nil?

      response = post("/authorize/v1/#{MCP_CAPABILITIES_ROUTE}/evaluate", params)[:response]
      {
        allowed_capabilities: response[:allowed_capabilities],
        authorized: response[:authorized],
        expires_at: response[:expires_at],
        user_id: response[:user_id],
        non_human_identity: response[:non_human_identity],
        policy_version_id: response[:policy_version_id]
      }
    end
  end
end
