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

  if Gem.loaded_specs['duo_api']
    VERSION = Gem.loaded_specs['duo_api'].version
  else
    VERSION = '0.0.0'
  end

  # Constants for handling rate limit backoff
  MAX_BACKOFF_WAIT_SECS = 32
  INITIAL_BACKOFF_WAIT_SECS = 1
  BACKOFF_FACTOR = 2
  RATE_LIMITED_RESP_CODE = '429'

  def initialize(ikey, skey, host, proxy = nil, ca_file: nil)
    @ikey = ikey
    @skey = skey
    @host = host
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
      File.join(File.dirname(__FILE__), '..', 'ca_certs.pem')
  end

  def request(method, path, params = {}, additional_headers = nil)
    params_go_in_body = %w[POST PUT PATCH].include?(method)
    if params_go_in_body
      body = canon_json(params)
      params = {}
    else
      body = ''
    end

    uri = request_uri(path, params)
    current_date, signed = sign(method, uri.host, path, params, body, additional_headers)

    request = Net::HTTP.const_get(method.capitalize).new uri.to_s
    request.basic_auth(@ikey, signed)
    request['Date'] = current_date
    request['User-Agent'] = "duo_api_ruby/#{VERSION}"
    if params_go_in_body
      request['Content-Type'] = 'application/json'
      request.body = body
    end

    Net::HTTP.start(
      uri.host, uri.port, *@proxy,
      use_ssl: true, ca_file: @ca_file,
      verify_mode: OpenSSL::SSL::VERIFY_PEER
    ) do |http|
      wait_secs = INITIAL_BACKOFF_WAIT_SECS
      while true do
        resp = http.request(request)
        if resp.code != RATE_LIMITED_RESP_CODE or wait_secs > MAX_BACKOFF_WAIT_SECS
          return resp
        end
        random_offset = rand()
        sleep(wait_secs + random_offset)
        wait_secs *= BACKOFF_FACTOR
      end
    end
  end

  private

  def encode_key_val(k, v)
    # encode the key and the value for a url
    key = ERB::Util.url_encode(k.to_s)
    value = ERB::Util.url_encode(v.to_s)
    key + '=' + value
  end

  def canon_params(params_hash = nil)
    return '' if params_hash.nil?
    params_hash.sort.map do |k, v|
      # when it is an array, we want to add that as another param
      # eg. next_offset = ['1547486297000', '5bea1c1e-612c-4f1d-b310-75fd31385b15']
      if v.is_a?(Array)
        encode_key_val(k, v[0]) + '&' + encode_key_val(k, v[1])
      else
        encode_key_val(k, v)
      end
    end.join('&')
  end

  def canon_json(params_hash = nil)
    return '' if params_hash.nil?
    JSON.generate(Hash[params_hash.sort])
  end

  def canon_x_duo_headers(additional_headers)
    additional_headers ||= {}

    if not additional_headers.select{|k,v| k.nil? or v.nil?}.empty?
      raise 'Not allowed "nil" as a header name or value'
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

  def validate_additional_header(header_name, value, added_headers)
    raise 'Not allowed "Null" character in header name' if header_name.include?("\x00")
    raise 'Not allowed "Null" character in header value' if value.include?("\x00")
    raise 'Additional headers must start with \'X-Duo-\'' unless header_name.downcase.start_with?('x-duo-')
    raise "Duplicate header passed, header=#{header_name}" if added_headers.include?(header_name.downcase)
  end

  def request_uri(path, params = nil)
    u = 'https://' + @host + path
    u += '?' + canon_params(params) unless params.nil?
    URI.parse(u)
  end

  def canonicalize(method, host, path, params, body = '', additional_headers = nil, options: {})
    # options[:date] being passed manually is specifically for tests
    date = options[:date] || Time.now.rfc2822()
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

  def sign(method, host, path, params, body = '', additional_headers = nil, options: {})
    # options[:date] being passed manually is specifically for tests
    date, canon = canonicalize(method, host, path, params, body, additional_headers, options: options)
    [date, OpenSSL::HMAC.hexdigest('sha512', @skey, canon)]
  end
end
