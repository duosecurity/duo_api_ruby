# frozen_string_literal: true

require_relative 'common'

class TestHelpersBasic < HTTPTestCase
  def test_get_ok
    @mock_http.expects(:request).returns(@json_ok_str_resp)
    actual_response = @client.get('/fake')
    assert_equal(parse_json_to_sym_hash(@json_ok_str_resp.body), actual_response)
  end

  def test_get_fail
    @mock_http.expects(:request).returns(@json_fail_resp)
    assert_raise_with_message(
      DuoApi::ResponseCodeError,
      "HTTP #{@json_fail_resp.code}: #{@json_fail_resp.body}"
    ){ @client.get('/fake') }
  end

  def test_get_invalid_response_format
    @mock_http.expects(:request).returns(@json_invalid_resp)
    assert_raise(JSON::ParserError){ @client.get('/fake') }
  end

  def test_get_invalid_response_content_type
    @mock_http.expects(:request).returns(@image_ok_resp)
    assert_raise_with_message(
      DuoApi::ContentTypeError,
      'Invalid Content-Type image/png, should match "application/json"'
    ){ @client.get('/fake') }
  end

  def test_get_ratelimit_timeout
    @mock_http.expects(:request).times(7).returns(@ratelimit_resp)
    @client.expects(:rand).times(6).returns(0.123)
    @client.expects(:sleep).with(1.123)
    @client.expects(:sleep).with(2.123)
    @client.expects(:sleep).with(4.123)
    @client.expects(:sleep).with(8.123)
    @client.expects(:sleep).with(16.123)
    @client.expects(:sleep).with(32.123)
    assert_raise_with_message(
      DuoApi::RateLimitError,
      'Rate limit retry max wait exceeded'
    ){ @client.get('/fake') }
  end

  def test_get_all_ok
    @mock_http.expects(:request).returns(@json_ok_arr_resp)
    actual_response = @client.get_all('/fake')
    assert_equal(parse_json_to_sym_hash(@json_ok_arr_resp.body), actual_response)
  end

  def test_get_all_fail
    @mock_http.expects(:request).returns(@json_fail_resp)
    assert_raise_with_message(
      DuoApi::ResponseCodeError,
      "HTTP #{@json_fail_resp.code}: #{@json_fail_resp.body}"
    ){ @client.get_all('/fake') }
  end

  def test_get_all_invalid
    @mock_http.expects(:request).returns(@json_invalid_resp)
    assert_raise(JSON::ParserError){ @client.get_all('/fake') }
  end

  def test_get_image_ok
    @mock_http.expects(:request).returns(@image_ok_resp)
    actual_response = @client.get_image('/fake')
    assert_equal(@image_ok_resp.body, actual_response)
  end

  def test_get_image_fail
    @mock_http.expects(:request).returns(@json_fail_resp)
    assert_raise_with_message(
      DuoApi::ResponseCodeError,
      "HTTP #{@json_fail_resp.code}: #{@json_fail_resp.body}"
    ){ @client.get_image('/fake') }
  end

  def test_get_image_invalid_response_content_type
    @mock_http.expects(:request).returns(@json_ok_str_resp)
    assert_raise_with_message(
      DuoApi::ContentTypeError,
      'Invalid Content-Type application/json, should match /^image\//'
    ){ @client.get_image('/fake') }
  end

  def test_post_ok
    @mock_http.expects(:request).returns(@json_ok_str_resp)
    actual_response = @client.post('/fake')
    assert_equal(parse_json_to_sym_hash(@json_ok_str_resp.body), actual_response)
  end

  def test_post_fail
    @mock_http.expects(:request).returns(@json_fail_resp)
    assert_raise_with_message(
      DuoApi::ResponseCodeError,
      "HTTP #{@json_fail_resp.code}: #{@json_fail_resp.body}"
    ){ @client.post('/fake') }
  end

  def test_post_invalid_response_format
    @mock_http.expects(:request).returns(@json_invalid_resp)
    assert_raise(JSON::ParserError){ @client.post('/fake') }
  end

  def test_post_invalid_response_content_type
    @mock_http.expects(:request).returns(@image_ok_resp)
    assert_raise_with_message(
      DuoApi::ContentTypeError,
      'Invalid Content-Type image/png, should match "application/json"'
    ){ @client.post('/fake') }
  end

  def test_put_ok
    @mock_http.expects(:request).returns(@json_ok_str_resp)
    actual_response = @client.put('/fake')
    assert_equal(parse_json_to_sym_hash(@json_ok_str_resp.body), actual_response)
  end

  def test_put_fail
    @mock_http.expects(:request).returns(@json_fail_resp)
    assert_raise_with_message(
      DuoApi::ResponseCodeError,
      "HTTP #{@json_fail_resp.code}: #{@json_fail_resp.body}"
    ){ @client.put('/fake') }
  end

  def test_put_invalid_response_format
    @mock_http.expects(:request).returns(@json_invalid_resp)
    assert_raise(JSON::ParserError){ @client.put('/fake') }
  end

  def test_put_invalid_response_content_type
    @mock_http.expects(:request).returns(@image_ok_resp)
    assert_raise_with_message(
      DuoApi::ContentTypeError,
      'Invalid Content-Type image/png, should match "application/json"'
    ){ @client.put('/fake') }
  end

  def test_delete_ok
    @mock_http.expects(:request).returns(@json_ok_str_resp)
    actual_response = @client.delete('/fake')
    assert_equal(parse_json_to_sym_hash(@json_ok_str_resp.body), actual_response)
  end

  def test_delete_fail
    @mock_http.expects(:request).returns(@json_fail_resp)
    assert_raise_with_message(
      DuoApi::ResponseCodeError,
      "HTTP #{@json_fail_resp.code}: #{@json_fail_resp.body}"
    ){ @client.delete('/fake') }
  end

  def test_delete_invalid_response_format
    @mock_http.expects(:request).returns(@json_invalid_resp)
    assert_raise(JSON::ParserError){ @client.delete('/fake') }
  end

  def test_delete_invalid_response_content_type
    @mock_http.expects(:request).returns(@image_ok_resp)
    assert_raise_with_message(
      DuoApi::ContentTypeError,
      'Invalid Content-Type image/png, should match "application/json"'
    ){ @client.delete('/fake') }
  end
end

class TestHelpersPaginated < HTTPTestCase
  setup
  def setup_test_globals
    @standard_paged_response1 = Net::HTTPSuccess.new(
      '200',
      {
        stat: 'OK',
        response: %w[RESPONSE1 RESPONSE2],
        metadata: {
          total_objects: 4,
          next_offset: 2,
          prev_offset: 0
        }
      },
      { 'Content-Type': 'application/json' }
    )

    @standard_paged_response2 = Net::HTTPSuccess.new(
      '200',
      JSON.generate({
        stat: 'OK',
        response: %w[RESPONSE3 RESPONSE4],
        metadata: {
          total_objects: 4,
          prev_offset: 2
        }
      }),
      { 'Content-Type': 'application/json' }
    )

    @standard_paged_combined_results = {
      stat: 'OK',
      response: %w[RESPONSE1 RESPONSE2 RESPONSE3 RESPONSE4],
      metadata: {
        total_objects: 4,
        prev_offset: 2
      }
    }

    @nonstandard_paged_response1 = Net::HTTPSuccess.new(
      '200',
      JSON.generate({
        stat: 'OK',
        response: {
          items: %w[RESPONSE1 RESPONSE2],
          metadata: {
            next_offset: %w[1738997429000 cb306faf-7f36-494d-9a0e-5697d93331f8]
          }
        }
      }),
      { 'Content-Type': 'application/json' }
    )

    @nonstandard_paged_response2 = Net::HTTPSuccess.new(
      '200',
      JSON.generate({
        stat: 'OK',
        response: {
          items: %w[RESPONSE3 RESPONSE4],
          metadata: {}
        }
      }),
      { 'Content-Type': 'application/json' }
    )

    @nonstandard_paged_combined_results = {
      stat: 'OK',
      response: {
        items: %w[RESPONSE1 RESPONSE2 RESPONSE3 RESPONSE4],
        metadata: {}
      }
    }
  end

  def test_get_all_standard_paged_ok
    @mock_http.expects(:request).twice.returns(
      @standard_paged_response1, @standard_paged_response2
    )
    actual_response = @client.get_all('/fake')
    assert_equal(@standard_paged_combined_results, actual_response)
  end

  def test_get_all_nonstandard_paged_ok
    @mock_http.expects(:request).twice.returns(
      @nonstandard_paged_response1, @nonstandard_paged_response2
    )
    actual_response = @client.get_all('/fake',
                                      data_array_path: %w[response items],
                                      metadata_path: %w[response metadata])
    assert_equal(@nonstandard_paged_combined_results, actual_response)
  end

  def test_get_all_bad_data_array_path
    @mock_http.expects(:request).returns(@nonstandard_paged_response1)
    assert_raise_with_message(
      DuoApi::PaginationError,
      'Object at data_array_path ["response"] is not an Array'
    ){ @client.get_all('/fake', metadata_path: %w[response metadata]) }
  end
end

class TestHelpersPrivateArrayFormatters < BaseTestCase
  setup
  def setup_test_globals
    @client = DuoApi.new(IKEY, SKEY, HOST)

    @array = %w[ITEM1 ITEM2 ITEM3]

    @json_serialized_array = '["ITEM1","ITEM2","ITEM3"]'

    @csv_serialized_array = 'ITEM1,ITEM2,ITEM3'
  end

  def test_json_serialized_array_input_array
    actual = @client.send(:json_serialized_array, @array)
    assert_equal(actual, @json_serialized_array)
  end

  def test_json_serialized_array_input_string
    actual = @client.send(:json_serialized_array, @json_serialized_array)
    assert_equal(actual, @json_serialized_array)
  end

  def test_csv_serialized_array_input_array
    actual = @client.send(:csv_serialized_array, @array)
    assert_equal(actual, @csv_serialized_array)
  end

  def test_csv_serialized_array_input_string
    actual = @client.send(:csv_serialized_array, @csv_serialized_array)
    assert_equal(actual, @csv_serialized_array)
  end
end

class TestHelpersPrivateBooleanFormatters < BaseTestCase
  setup
  def setup_test_globals
    @client = DuoApi.new(IKEY, SKEY, HOST)

    @bool_true = true

    @string_true = 'TRUE'

    @string_int_true = '1'

    @int_true = 1

    @bool_false = false

    @string_false = 'FALSE'

    @string_int_false = '0'

    @int_false = 0

    @random_object = Object.new

    @stringified_python_boolean_true = 'True'

    @stringified_python_boolean_false = 'False'
  end

  def test_stringified_python_boolean_input_bool_true
    actual = @client.send(:stringified_python_boolean, @bool_true)
    assert_equal(actual, @stringified_python_boolean_true)
  end

  def test_stringified_python_boolean_input_string_true
    actual = @client.send(:stringified_python_boolean, @string_true)
    assert_equal(actual, @stringified_python_boolean_true)
  end
end
