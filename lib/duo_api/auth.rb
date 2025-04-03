# frozen_string_literal: true

require_relative 'api_client'
require_relative 'api_helpers'

class DuoApi
  ##
  # Duo Auth API (https://duo.com/docs/authapi)
  #
  class Auth < DuoApi
    def ping
      get('/auth/v2/ping')[:response]
    end

    def check
      get('/auth/v2/check')[:response]
    end

    def logo
      get_image('/auth/v2/logo')
    end

    def enroll(**optional_params)
      # optional_params: username, valid_secs
      post('/auth/v2/enroll', optional_params)[:response]
    end

    def enroll_status(user_id:, activation_code:)
      params = { user_id: user_id, activation_code: activation_code }
      post('/auth/v2/enroll_status', params)[:response]
    end

    def preauth(**optional_params)
      # optional_params: user_id, username, client_supports_verified_push, ipaddr, hostname,
      #                  trusted_device_token
      #
      # Note: user_id or username must be provided
      optional_params.tap do |p|
        if p[:client_supports_verified_push]
          p[:client_supports_verified_push] =
            stringified_binary_boolean(p[:client_supports_verified_push])
        end
      end
      post('/auth/v2/preauth', optional_params)[:response]
    end

    def auth(factor:, **optional_params)
      # optional_params: user_id, username, ipaddr, hostname, async
      #
      # Note: user_id or username must be provided
      optional_params.tap do |p|
        p[:async] = stringified_binary_boolean(p[:async]) if p[:async]
      end
      params = optional_params.merge({ factor: factor })
      post('/auth/v2/auth', params)[:response]
    end

    def auth_status(txid:)
      params = { txid: txid }
      get('/auth/v2/auth_status', params)[:response]
    end
  end
end
