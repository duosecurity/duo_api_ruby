# frozen_string_literal: true

require_relative 'common'

##
# DuoApi::Device tests
#
class TestDevice < HTTPTestCase
  setup
  def setup_test_globals
    @device_api = DuoApi::Device.new(IKEY, SKEY, HOST, mkey: 'MKEY')

    @devices_retrieved_ok_resp = Net::HTTPSuccess.new(
      '200',
      {
        stat: 'OK',
        response: {
          cache_key: 'CACHEKEY',
          devices_retrieved: [
            {
              date_added: 'DATEADDED',
              device_id: 'DEVICEID'
            }
          ],
          num_devices_retrieved: 1
        }
      },
      { 'Content-Type': 'application/json' }
    )
  end

  def test_create_device_cache
    @mock_http.expects(:request).returns(@json_ok_hsh_resp)
    assert_nothing_raised{ @device_api.create_device_cache }
  end

  def test_create_device_cache_optional_args
    @mock_http.expects(:request).returns(@json_ok_hsh_resp)
    optional = { things: 'AND STUFF' }
    assert_nothing_raised{ @device_api.create_device_cache(**optional) }
  end

  def test_add_device_cache_devices
    @mock_http.expects(:request).returns(@json_ok_hsh_resp)
    required = { cache_key: 'CACHEKEY', devices: [{ device_id: 'DEVICEID1' }] }
    assert_nothing_raised{ @device_api.add_device_cache_devices(**required) }
  end

  def test_add_device_cache_devices_args_missing
    @mock_http.expects(:request).times(0)
    required = %i[cache_key devices]
    assert_raise_with_message(
      ArgumentError,
      missing_keywords_message(required)
    ){ @device_api.add_device_cache_devices }
  end

  def test_get_device_cache_devices
    @mock_http.expects(:request).returns(@devices_retrieved_ok_resp)
    required = { cache_key: 'CACHEKEY' }
    assert_nothing_raised{ @device_api.get_device_cache_devices(**required) }
  end

  def test_get_device_cache_devices_optional_args
    @mock_http.expects(:request).returns(@devices_retrieved_ok_resp)
    required = { cache_key: 'CACHEKEY' }
    optional = { things: 'AND STUFF' }
    assert_nothing_raised{ @device_api.get_device_cache_devices(**required, **optional) }
  end

  def test_get_device_cache_devices_args_missing
    @mock_http.expects(:request).times(0)
    required = %i[cache_key]
    assert_raise_with_message(
      ArgumentError,
      missing_keywords_message(required)
    ){ @device_api.get_device_cache_devices }
  end

  def test_delete_device_cache_devices
    @mock_http.expects(:request).returns(@json_ok_hsh_resp)
    required = { cache_key: 'CACHEKEY', devices: ['DEVICEID1'] }
    assert_nothing_raised{ @device_api.delete_device_cache_devices(**required) }
  end

  def test_delete_device_cache_devices_args_missing
    @mock_http.expects(:request).times(0)
    required = %i[cache_key devices]
    assert_raise_with_message(
      ArgumentError,
      missing_keywords_message(required)
    ){ @device_api.delete_device_cache_devices }
  end

  def test_activate_device_cache
    @mock_http.expects(:request).returns(@json_ok_str_resp)
    required = { cache_key: 'CACHEKEY' }
    assert_nothing_raised{ @device_api.activate_device_cache(**required) }
  end

  def test_activate_device_cache_args_missing
    @mock_http.expects(:request).times(0)
    required = %i[cache_key]
    assert_raise_with_message(
      ArgumentError,
      missing_keywords_message(required)
    ){ @device_api.activate_device_cache }
  end

  def test_delete_device_cache
    @mock_http.expects(:request).returns(@json_ok_str_resp)
    required = { cache_key: 'CACHEKEY' }
    assert_nothing_raised{ @device_api.delete_device_cache(**required) }
  end

  def test_delete_device_cache_args_missing
    @mock_http.expects(:request).times(0)
    required = %i[cache_key]
    assert_raise_with_message(
      ArgumentError,
      missing_keywords_message(required)
    ){ @device_api.delete_device_cache }
  end

  def test_get_device_caches
    @mock_http.expects(:request).returns(@json_ok_arr_resp)
    required = { status: 'active' }
    assert_nothing_raised{ @device_api.get_device_caches(**required) }
  end

  def test_get_device_caches_args_missing
    @mock_http.expects(:request).times(0)
    required = %i[status]
    assert_raise_with_message(
      ArgumentError,
      missing_keywords_message(required)
    ){ @device_api.get_device_caches }
  end

  def test_get_device_cache
    @mock_http.expects(:request).returns(@json_ok_hsh_resp)
    required = { cache_key: 'CACHEKEY' }
    assert_nothing_raised{ @device_api.get_device_cache(**required) }
  end

  def test_get_device_cache_args_missing
    @mock_http.expects(:request).times(0)
    required = %i[cache_key]
    assert_raise_with_message(
      ArgumentError,
      missing_keywords_message(required)
    ){ @device_api.get_device_cache }
  end
end
