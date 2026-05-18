# frozen_string_literal: true

require_relative 'api_client'
require_relative 'api_helpers'

class DuoApi
  ##
  # Duo Authorization API
  #
  class Authorization < DuoApi
    McpCapabilities = Data.define(:access_token, :mcp_server_id, :mcp_server_name, :tool) do
      def initialize(access_token:, mcp_server_id:, mcp_server_name: '', tool: nil)
        super
      end

      def route_fragment
        'mcp_capabilities'
      end
    end

    def ping
      get('/authorize/v1/ping')[:response]
    end

    def check
      get('/authorize/v1/check')[:response]
    end

    def evaluate(input)
      params = {
        access_token: input.access_token,
        mcp_server_id: input.mcp_server_id,
        mcp_server_name: input.mcp_server_name
      }
      params[:tool] = input.tool unless input.tool.nil?

      response = post("/authorize/v1/#{input.route_fragment}/evaluate", params)[:response]
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
