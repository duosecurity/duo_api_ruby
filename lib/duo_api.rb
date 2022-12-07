require 'erb'
require 'openssl'
require 'net/https'
require 'time'
require 'uri'

##
# A Ruby implementation of the Duo API
#
class DuoApi
  attr_accessor :ca_file

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

  def request(method, path, params = nil)
    uri = request_uri(path, params)
    current_date, signed = sign(method, uri.host, path, params)

    request = Net::HTTP.const_get(method.capitalize).new uri.to_s
    request.basic_auth(@ikey, signed)
    request['Date'] = current_date
    request['User-Agent'] = 'duo_api_ruby/1.3.0'

    Net::HTTP.start(uri.host, uri.port, *@proxy,
                    use_ssl: true, ca_file: @ca_file,
                    verify_mode: OpenSSL::SSL::VERIFY_PEER) do |http|
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

  def encode_params(params_hash = nil)
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

  def time
    Time.now.rfc2822
  end

  def request_uri(path, params = nil)
    u = 'https://' + @host + path
    u += '?' + encode_params(params) unless params.nil?
    URI.parse(u)
  end

  def canonicalize(method, host, path, params, options = {})
    options[:date] ||= time
    canon = [
      options[:date],
      method.upcase,
      host.downcase,
      path,
      encode_params(params)
    ]
    [options[:date], canon.join("\n")]
  end

  def sign(method, host, path, params, options = {})
    date, canon = canonicalize(method, host, path, params, date: options[:date])
    [date, OpenSSL::HMAC.hexdigest('sha512', @skey, canon)]
  end
end
