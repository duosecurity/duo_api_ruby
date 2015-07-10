require "openssl"
require 'net/https'
require 'time'
require 'uri'

class DuoApi
  @@encode_regex = Regexp.new("[^-_.~a-zA-Z\\d]")

  def initialize(ikey, skey, host, proxy=nil)
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
  end

  def request(method, path, params=nil)
    uri = request_uri(path, params)
    current_date, signed = sign(method, uri.host, path, params)

    request = Net::HTTP.const_get(method.capitalize).new uri.to_s
    request.basic_auth(@ikey, signed)
    request['Date'] = current_date

    ca_file = File.join(File.dirname(__FILE__), "ca_certs.pem")

    Net::HTTP.start(uri.host, uri.port, *@proxy,
                    :use_ssl => true, :ca_file => ca_file,
                    :verify_mode => OpenSSL::SSL::VERIFY_PEER) do |http|
      http.request(request)
    end
  end

  private
  def encode_params(params_hash=nil)
    return "" if params_hash.nil?
    params_hash.sort.map do |k,v|
      URI::encode(k.to_s, @@encode_regex) + "=" + URI::encode(v.to_s, @@encode_regex)
    end.join("&")
  end

  def get_time
    Time.now.rfc2822
  end

  def request_uri(path, params=nil)
    u = 'https://' + @host + path
    u += '?' + encode_params(params) unless params.nil?
    URI.parse(u)
  end

  def canonicalize(method, host, path, params, options={})
    options[:date] ||= get_time
    canon = [
      options[:date],
      method.upcase,
      host.downcase,
      path,
      encode_params(params)
    ]
    [options[:date], canon.join("\n")]
  end

  def sign(method, host, path, params, options={})
    date, canon = canonicalize(method, host, path, params, :date => options[:date])
    [date, OpenSSL::HMAC.hexdigest(OpenSSL::Digest::SHA1.new, @skey, canon)]
  end
end
