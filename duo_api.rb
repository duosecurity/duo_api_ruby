require 'digest/hmac'
require 'net/https'
require 'time'
require 'uri'

class DuoApi
  @@encode_regex = Regexp.new("[^-_.~a-zA-Z\\d]")

  def initialize(ikey, skey, host)
    @ikey = ikey
    @skey = skey
    @host = host
  end

  def request(method, path, params=nil)
    uri = request_uri(path, params)
    current_date, signed = sign(method, uri.host, path, params, @skey)

    request = Net::HTTP.const_get(method.capitalize).new uri.to_s
    request.basic_auth(@ikey, signed)
    request['Date'] = current_date

    ca_file = File.join(File.dirname(__FILE__), "cacert.pem")

    response = Net::HTTP.start(uri.host, uri.port,
                               :use_ssl => true, :ca_file => ca_file) do |http|
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

  def sign(method, host, path, params, skey, options={})
    date, canon = canonicalize(method, host, path, params, :date => options[:date])
    [date, Digest::HMAC.hexdigest(canon, @skey, Digest::SHA1)]
  end
end
