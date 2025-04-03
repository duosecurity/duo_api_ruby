# frozen_string_literal: true

require 'test/unit'
require 'mocha/test_unit'

require 'duo_api'

IKEY = 'test_ikey'
SKEY = 'gtdfxv9YgVBYcF6dl2Eq17KUQJN2PLM2ODVTkvoT'
HOST = 'foO.BAr52.cOm'

# Custom MockResponse object to simulate basics of Net::HTTPResponse
module MockResponse
  def initialize(code, body = nil, headers = {})
    @code = code.to_s
    @body = body.is_a?(Hash) ? JSON.generate(body) : body
    @headers = headers.transform_keys{ |k| k.to_s.downcase.to_sym }
  end

  def code
    @code
  end

  def body
    @body
  end

  def headers
    @headers
  end

  def [](key)
    standardized_key = key.to_s.downcase.to_sym
    headers[standardized_key]
  end

  def to_hash
    headers
  end

  def to_s
    [
      'HTTP Status Code:', code,
      'HTTP Headers:', headers,
      'HTTP Body:', body
    ].join("\n")
  end
end

# Override classes in Net module so we can mock them
module Net
  class HTTPSuccess
    include MockResponse
  end

  class HTTPTooManyRequests
    include MockResponse
  end

  class HTTPBadRequest
    include MockResponse
  end
end

##
# Custom Test Cases
#
class BaseTestCase < Test::Unit::TestCase
  def setup
    @client = DuoApi.new(IKEY, SKEY, HOST)
  end
end

class HTTPTestCase < BaseTestCase
  setup
  def setup_http
    @mock_http = mock
    Net::HTTP.expects(:start).times(0..2).yields(@mock_http)
  end

  setup
  def setup_shared_globals
    @ok_resp = Net::HTTPSuccess.new('200')

    @ratelimit_resp = Net::HTTPTooManyRequests.new('429')

    @json_ok_str_resp = Net::HTTPSuccess.new(
      '200',
      {
        stat: 'OK',
        response: 'RESPONSE STRING'
      },
      { 'Content-Type': 'application/json' }
    )

    @json_ok_hsh_resp = Net::HTTPSuccess.new(
      '200',
      {
        stat: 'OK',
        response: { KEY: 'VALUE' }
      },
      { 'Content-Type': 'application/json' }
    )

    @json_ok_arr_resp = Net::HTTPSuccess.new(
      '200',
      {
        stat: 'OK',
        response: %w[RESPONSE1 RESPONSE2]
      },
      { 'Content-Type': 'application/json' }
    )

    @json_fail_resp = Net::HTTPBadRequest.new(
      '400',
      {
        stat: 'FAIL',
        message: 'ERROR MESSAGE',
        message_detail: 'ERROR MESSAGE DETAIL'
      },
      { 'Content-Type': 'application/json' }
    )

    @json_invalid_resp = Net::HTTPSuccess.new(
      '200',
      'This is not valid JSON.',
      { 'Content-Type': 'application/json' }
    )

    @image_ok_resp = Net::HTTPSuccess.new(
      '200',
      Base64.decode64('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAAAXNSR0IArs4c6QAAAA1JREFUGFdjyN7v9x8ABYkCeCbwZG' \
                      'wAAAAASUVORK5CYII='),
      { 'Content-Type': 'image/png' }
    )
  end
end

# Override StandardError to get rid of backtraces on errors for tests
class StandardError
  def backtrace
    []
  end
end

# Parse JSON string to Hash with symbol keys
def parse_json_to_sym_hash(json)
  JSON.parse(json, symbolize_names: true)
end

# Format ArgumentError messages for missing keywords
def missing_keywords_message(required_keywords)
  return if required_keywords.count < 1

  msg = 'missing keyword'
  msg += 's' if required_keywords.count > 1
  msg += ": :#{required_keywords.join(', :')}"
  msg
end
