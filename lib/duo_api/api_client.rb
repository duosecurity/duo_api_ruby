# frozen_string_literal: true

require 'base64'
require 'erb'
require 'json'
require 'openssl'
require 'net/https'
require 'time'
require 'uri'

##
# A Ruby implementation of the Duo API
#
class DuoApi
  attr_accessor :ca_file
  attr_reader :default_params

  VERSION = Gem.loaded_specs['duo_api'] ? Gem.loaded_specs['duo_api'].version : '0.0.0'

  # Constants for handling rate limit backoff
  MAX_BACKOFF_WAIT_SECS = 32
  INITIAL_BACKOFF_WAIT_SECS = 1
  BACKOFF_FACTOR = 2

  def initialize(ikey, skey, host, proxy = nil, ca_file: nil, default_params: {})
    @ikey = ikey
    @skey = skey
    @host = host
    @proxy_str = proxy
    if proxy.nil?
      @proxy = []
    else
      proxy_uri = URI.parse proxy
      @proxy = [
        proxy_uri.host,
        proxy_uri.port,
        proxy_uri.user,
        proxy_uri.password
      ]
    end
    @ca_file = ca_file ||
               File.join(File.dirname(__FILE__), '..', '..', 'ca_certs.pem')
    @default_params = default_params.transform_keys(&:to_sym)
  end

  def default_params=(default_params)
    @default_params = default_params.transform_keys(&:to_sym)
  end

  # Basic authenticated request returning raw Net::HTTPResponse object
  def request(method, path, params = {}, additional_headers = nil)
    # Merge default params with provided params
    params = @default_params.merge(params.transform_keys(&:to_sym))

    # Determine if params should be in a JSON request body
    params_go_in_body = %w[POST PUT PATCH].include?(method)
    if params_go_in_body
      body = canon_json(params)
      params = {}
    else
      body = ''
    end

    # Construct the request URI
    uri = request_uri(path, params)

    # Sign the request
    current_date, signed = sign(method, uri.host, path, params, body, additional_headers)

    # Create the HTTP request object
    request = Net::HTTP.const_get(method.capitalize).new(uri.to_s)
    request.basic_auth(@ikey, signed)
    request['Date'] = current_date
    request['User-Agent'] = "duo_api_ruby/#{VERSION}"

    # Set Content-Type and request body for JSON requests
    if params_go_in_body
      request['Content-Type'] = 'application/json'
      request.body = body
    end

    # Start the HTTP session
    Net::HTTP.start(
      uri.host, uri.port, *@proxy,
      use_ssl: true, ca_file: @ca_file,
      verify_mode: OpenSSL::SSL::VERIFY_PEER
    ) do |http|
      wait_secs = INITIAL_BACKOFF_WAIT_SECS
      loop do
        resp = http.request(request)

        # Check if the response is rate-limited and handle backoff
        return resp if !resp.is_a?(Net::HTTPTooManyRequests) || (wait_secs > MAX_BACKOFF_WAIT_SECS)

        random_offset = rand
        sleep(wait_secs + random_offset)
        wait_secs *= BACKOFF_FACTOR
      end
    end
  end

  private

  # Encode a key-value pair for a URL
  def encode_key_val(key, val)
    key = ERB::Util.url_encode(key.to_s)
    value = ERB::Util.url_encode(val.to_s)
    "#{key}=#{value}"
  end

  # Build a canonical parameter string
  def canon_params(params_hash = nil)
    return '' if params_hash.nil?

    params_hash.transform_keys(&:to_s).sort.map do |k, v|
      # When value an array, repeat key for each unique value in sorted array
      if v.is_a?(Array)
        if v.count.positive?
          v.sort.uniq.map{ |vn| encode_key_val(k, vn) }.join('&')
        else
          encode_key_val(k, '')
        end
      else
        encode_key_val(k, v)
      end
    end.join('&')
  end

  # Generate a canonical JSON body
  def canon_json(params_hash = nil)
    return '' if params_hash.nil?

    JSON.generate(params_hash.sort.to_h)
  end

  # Canonicalize additional headers for signing
  def canon_x_duo_headers(additional_headers)
    additional_headers ||= {}

    unless additional_headers.none?{ |k, v| k.nil? || v.nil? }
      raise(HeaderError, 'Not allowed "nil" as a header name or value')
    end

    canon_list = []
    added_headers = []
    additional_headers.keys.sort.each do |header_name|
      header_name_lowered = header_name.downcase
      header_value = additional_headers[header_name]
      validate_additional_header(header_name_lowered, header_value, added_headers)
      canon_list.append(header_name_lowered, header_value)
      added_headers.append(header_name_lowered)
    end

    canon = canon_list.join("\x00")
    OpenSSL::Digest::SHA512.hexdigest(canon)
  end

  # Validate additional headers to ensure they meet requirements
  def validate_additional_header(header_name, value, added_headers)
    header_name.downcase!
    raise(HeaderError, 'Not allowed "Null" character in header name') if header_name.include?("\x00")
    raise(HeaderError, 'Not allowed "Null" character in header value') if value.include?("\x00")
    raise(HeaderError, 'Additional headers must start with \'X-Duo-\'') unless header_name.start_with?('x-duo-')
    raise(HeaderError, "Duplicate header passed, header=#{header_name}") if added_headers.include?(header_name)
  end

  # Construct the request URI
  def request_uri(path, params = nil)
    u = "https://#{@host}#{path}"
    u += "?#{canon_params(params)}" unless params.nil?
    URI.parse(u)
  end

  # Create a canonical string for signing requests
  def canonicalize(method, host, path, params, body = '', additional_headers = nil, options: {})
    # options[:date] being passed manually is specifically for tests
    date = options[:date] || Time.now.rfc2822
    canon = [
      date,
      method.upcase,
      host.downcase,
      path,
      canon_params(params),
      OpenSSL::Digest::SHA512.hexdigest(body),
      canon_x_duo_headers(additional_headers)
    ]
    [date, canon.join("\n")]
  end

  # Sign the request with HMAC-SHA512
  def sign(method, host, path, params, body = '', additional_headers = nil, options: {})
    # options[:date] being passed manually is specifically for tests
    date, canon = canonicalize(method, host, path, params, body, additional_headers, options: options)
    [date, OpenSSL::HMAC.hexdigest('sha512', @skey, canon)]
  end

  # Custom Error Classes
  class HeaderError < StandardError; end
  class RateLimitError < StandardError; end
  class ResponseCodeError < StandardError; end
  class ContentTypeError < StandardError; end
  class PaginationError < StandardError; end
  class ChildAccountError < StandardError; end
end
