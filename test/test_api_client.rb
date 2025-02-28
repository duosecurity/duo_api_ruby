# frozen_string_literal: true

require_relative 'common'

class TestCertificateAuthority < BaseTestCase
  def test_default_ca_file_exists
    assert_equal(true, File.exist?(@client.ca_file))
  end
end

class TestQueryParameters < BaseTestCase
  def assert_canon_params(params, expected)
    actual = @client.send(:canon_params, params)
    assert_equal(expected, actual)
  end

  def test_simple
    assert_canon_params(
      { realname: 'First Last', username: 'root' },
      'realname=First%20Last&username=root'
    )
  end

  def test_pagination_params
    assert_canon_params(
      { limit: '100', offset: '0' },
      'limit=100&offset=0'
    )
  end

  def test_zero_params
    assert_canon_params(
      {},
      ''
    )
  end

  def test_one_param
    assert_canon_params(
      { realname: 'First Last' },
      'realname=First%20Last'
    )
  end

  def test_array_param
    assert_canon_params(
      { realname: %w[First Last], something: 'test' },
      'realname=First&realname=Last&something=test'
    )
  end

  def test_printable_ascii_characters
    assert_canon_params(
      {
        digits: '0123456789',
        letters: 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ',
        punctuation: '!"#$%&\'()*+,-./:;<=>?@[\\]^_`{|}~',
        whitespace: "\t\n\x0b\x0c\r "
      },
      'digits=0123456789&letters=abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ&punctuation=%21%22%23%24%25%26%' \
      '27%28%29%2A%2B%2C-.%2F%3A%3B%3C%3D%3E%3F%40%5B%5C%5D%5E_%60%7B%7C%7D~&whitespace=%09%0A%0B%0C%0D%20'
    )
  end

  def test_unicode_fuzz_values
    assert_canon_params(
      {
        bar: "\u2815\uaaa3\u37cf\u4bb7\u36e9\ucc05\u668e\u8162\uc2bd\ua1f1",
        baz: "\u0df3\u84bd\u5669\u9985\ub8a4\uac3a\u7be7\u6f69\u934a\ub91c",
        foo: "\ud4ce\ud6d6\u7938\u50c0\u8a20\u8f15\ufd0b\u8024\u5cb3\uc655",
        qux: "\u8b97\uc846-\u828e\u831a\uccca\ua2d4\u8c3e\ub8b2\u99be"
      },
      'bar=%E2%A0%95%EA%AA%A3%E3%9F%8F%E4%AE%B7%E3%9B%A9%EC%B0%85%E6%9A%8E%E8%85%A2%EC%8A%BD%EA%87%B1&baz=%E0%B7%B3%E' \
      '8%92%BD%E5%99%A9%E9%A6%85%EB%A2%A4%EA%B0%BA%E7%AF%A7%E6%BD%A9%E9%8D%8A%EB%A4%9C&foo=%ED%93%8E%ED%9B%96%E7%A4%B' \
      '8%E5%83%80%E8%A8%A0%E8%BC%95%EF%B4%8B%E8%80%A4%E5%B2%B3%EC%99%95&qux=%E8%AE%97%EC%A1%86-%E8%8A%8E%E8%8C%9A%EC%' \
      'B3%8A%EA%8B%94%E8%B0%BE%EB%A2%B2%E9%A6%BE'
    )
  end

  def test_unicode_fuzz_keys_and_values
    assert_canon_params(
      {
        "\u469a\u287b\u35d0\u8ef3\u6727\u502a\u0810\ud091\u00c8\uc170":
          "\u0f45\u1a76\u341a\u654c\uc23f\u9b09\uabe2\u8343\u1b27\u60d0",
        "\u7449\u7e4b\uccfb\u59ff\ufe5f\u83b7\uadcc\u900c\ucfd1\u7813":
          "\u8db7\u5022\u92d3\u42ef\u207d\u8730\uacfe\u5617\u0946\u4e30",
        "\u7470\u9314\u901c\u9eae\u40d8\u4201\u82d8\u8c70\u1d31\ua042":
          "\u17d9\u0ba8\u9358\uaadf\ua42a\u48be\ufb96\u6fe9\ub7ff\u32f3",
        "\uc2c5\u2c1d\u2620\u3617\u96b3F\u8605\u20e8\uac21\u5934":
          "\ufba9\u41aa\ubd83\u840b\u2615\u3e6e\u652d\ua8b5\ud56bU"
      },
      '%E4%9A%9A%E2%A1%BB%E3%97%90%E8%BB%B3%E6%9C%A7%E5%80%AA%E0%A0%90%ED%82%91%C3%88%EC%85%B0=%E0%BD%85%E1%A9%B6%E3%' \
      '90%9A%E6%95%8C%EC%88%BF%E9%AC%89%EA%AF%A2%E8%8D%83%E1%AC%A7%E6%83%90&%E7%91%89%E7%B9%8B%EC%B3%BB%E5%A7%BF%EF%B' \
      '9%9F%E8%8E%B7%EA%B7%8C%E9%80%8C%EC%BF%91%E7%A0%93=%E8%B6%B7%E5%80%A2%E9%8B%93%E4%8B%AF%E2%81%BD%E8%9C%B0%EA%B3' \
      '%BE%E5%98%97%E0%A5%86%E4%B8%B0&%E7%91%B0%E9%8C%94%E9%80%9C%E9%BA%AE%E4%83%98%E4%88%81%E8%8B%98%E8%B1%B0%E1%B4%' \
      'B1%EA%81%82=%E1%9F%99%E0%AE%A8%E9%8D%98%EA%AB%9F%EA%90%AA%E4%A2%BE%EF%AE%96%E6%BF%A9%EB%9F%BF%E3%8B%B3&%EC%8B%' \
      '85%E2%B0%9D%E2%98%A0%E3%98%97%E9%9A%B3F%E8%98%85%E2%83%A8%EA%B0%A1%E5%A4%B4=%EF%AE%A9%E4%86%AA%EB%B6%83%E8%90%' \
      '8B%E2%98%95%E3%B9%AE%E6%94%AD%EA%A2%B5%ED%95%ABU'
    )
  end

  def test_encode_key_val
    actual = @client.send(:encode_key_val, 'one', 'two')
    assert_equal('one=two', actual)
  end
end

class TestCanonicalize < BaseTestCase
  def test_sig_v5_params
    params = {
      "\u469a\u287b\u35d0\u8ef3\u6727\u502a\u0810\ud091\u00c8\uc170":
        "\u0f45\u1a76\u341a\u654c\uc23f\u9b09\uabe2\u8343\u1b27\u60d0",
      "\u7449\u7e4b\uccfb\u59ff\ufe5f\u83b7\uadcc\u900c\ucfd1\u7813":
        "\u8db7\u5022\u92d3\u42ef\u207d\u8730\uacfe\u5617\u0946\u4e30",
      "\u7470\u9314\u901c\u9eae\u40d8\u4201\u82d8\u8c70\u1d31\ua042":
        "\u17d9\u0ba8\u9358\uaadf\ua42a\u48be\ufb96\u6fe9\ub7ff\u32f3",
      "\uc2c5\u2c1d\u2620\u3617\u96b3F\u8605\u20e8\uac21\u5934":
        "\ufba9\u41aa\ubd83\u840b\u2615\u3e6e\u652d\ua8b5\ud56bU"
    }
    body = ''
    additional_headers = nil
    expected_date = 'Fri, 07 Dec 2012 17:18:00 -0000'
    expected_canon = expected_date +
                     "\nPOST\nfoo.bar52.com\n/Foo/BaR2/qux\n%E4%9A%9A%E2%A1%BB%E3%97%90%E8%BB%B3%E6%9C%A7%E5%80%AA%E0" \
                     '%A0%90%ED%82%91%C3%88%EC%85%B0=%E0%BD%85%E1%A9%B6%E3%90%9A%E6%95%8C%EC%88%BF%E9%AC%89%EA%AF%A2%' \
                     'E8%8D%83%E1%AC%A7%E6%83%90&%E7%91%89%E7%B9%8B%EC%B3%BB%E5%A7%BF%EF%B9%9F%E8%8E%B7%EA%B7%8C%E9%8' \
                     '0%8C%EC%BF%91%E7%A0%93=%E8%B6%B7%E5%80%A2%E9%8B%93%E4%8B%AF%E2%81%BD%E8%9C%B0%EA%B3%BE%E5%98%97' \
                     '%E0%A5%86%E4%B8%B0&%E7%91%B0%E9%8C%94%E9%80%9C%E9%BA%AE%E4%83%98%E4%88%81%E8%8B%98%E8%B1%B0%E1%' \
                     'B4%B1%EA%81%82=%E1%9F%99%E0%AE%A8%E9%8D%98%EA%AB%9F%EA%90%AA%E4%A2%BE%EF%AE%96%E6%BF%A9%EB%9F%B' \
                     'F%E3%8B%B3&%EC%8B%85%E2%B0%9D%E2%98%A0%E3%98%97%E9%9A%B3F%E8%98%85%E2%83%A8%EA%B0%A1%E5%A4%B4=%' \
                     "EF%AE%A9%E4%86%AA%EB%B6%83%E8%90%8B%E2%98%95%E3%B9%AE%E6%94%AD%EA%A2%B5%ED%95%ABU\ncf83e1357eef" \
                     'b8bdf1542850d66d8007d620e4050b5715dc83f4a921d36ce9ce47d0d13c5d85f2b0ff8318d2877eec2f63b931bd474' \
                     "17a81a538327af927da3e\ncf83e1357eefb8bdf1542850d66d8007d620e4050b5715dc83f4a921d36ce9ce47d0d13c" \
                     '5d85f2b0ff8318d2877eec2f63b931bd47417a81a538327af927da3e'
    actual_date, actual_canon = @client.send(:canonicalize, 'PoSt', HOST, '/Foo/BaR2/qux', params, body,
                                             additional_headers, options: { date: expected_date })
    assert_equal(expected_canon, actual_canon)
    assert_equal(expected_date, actual_date)
  end

  def test_sig_v5_json
    params_hash = {
      "\u469a\u287b\u35d0\u8ef3\u6727\u502a\u0810\ud091\u00c8\uc170":
        "\u0f45\u1a76\u341a\u654c\uc23f\u9b09\uabe2\u8343\u1b27\u60d0",
      "\u7449\u7e4b\uccfb\u59ff\ufe5f\u83b7\uadcc\u900c\ucfd1\u7813":
        "\u8db7\u5022\u92d3\u42ef\u207d\u8730\uacfe\u5617\u0946\u4e30",
      "\u7470\u9314\u901c\u9eae\u40d8\u4201\u82d8\u8c70\u1d31\ua042":
        "\u17d9\u0ba8\u9358\uaadf\ua42a\u48be\ufb96\u6fe9\ub7ff\u32f3",
      "\uc2c5\u2c1d\u2620\u3617\u96b3F\u8605\u20e8\uac21\u5934":
        "\ufba9\u41aa\ubd83\u840b\u2615\u3e6e\u652d\ua8b5\ud56bU"
    }
    params = {}
    body = JSON.generate(params_hash.sort.to_h)
    additional_headers = nil
    expected_date = 'Fri, 07 Dec 2012 17:18:00 -0000'
    expected_canon = expected_date +
                     "\nPOST\nfoo.bar52.com\n/Foo/BaR2/qux\n\n069842dc1b1158ce098fb8cbabf4695fe5b6dbbe0189293c45253b8" \
                     "0522d6c56aaed43cfeeb541222d5a34d56f57e2b420b70856d1f09ba346418e7a5bca6397\ncf83e1357eefb8bdf154" \
                     '2850d66d8007d620e4050b5715dc83f4a921d36ce9ce47d0d13c5d85f2b0ff8318d2877eec2f63b931bd47417a81a53' \
                     '8327af927da3e'
    actual_date, actual_canon = @client.send(:canonicalize, 'PoSt', HOST, '/Foo/BaR2/qux', params, body,
                                             additional_headers, options: { date: expected_date })
    assert_equal(expected_canon, actual_canon)
    assert_equal(expected_date, actual_date)
  end
end

class TestSign < BaseTestCase
  def test_hmac_sha512
    params = {
      "\u469a\u287b\u35d0\u8ef3\u6727\u502a\u0810\ud091\u00c8\uc170":
        "\u0f45\u1a76\u341a\u654c\uc23f\u9b09\uabe2\u8343\u1b27\u60d0",
      "\u7449\u7e4b\uccfb\u59ff\ufe5f\u83b7\uadcc\u900c\ucfd1\u7813":
        "\u8db7\u5022\u92d3\u42ef\u207d\u8730\uacfe\u5617\u0946\u4e30",
      "\u7470\u9314\u901c\u9eae\u40d8\u4201\u82d8\u8c70\u1d31\ua042":
        "\u17d9\u0ba8\u9358\uaadf\ua42a\u48be\ufb96\u6fe9\ub7ff\u32f3",
      "\uc2c5\u2c1d\u2620\u3617\u96b3F\u8605\u20e8\uac21\u5934":
        "\ufba9\u41aa\ubd83\u840b\u2615\u3e6e\u652d\ua8b5\ud56bU"
    }
    body = ''
    additional_headers = nil
    expected_date = 'Fri, 07 Dec 2012 17:18:00 -0000'
    expected_sig = 'de886475f5ee8cf32872a7c10869e4dce7a0038f8b0da01d903469c6240473dfd1abf98b40b34b9ad7fbc99d5df3f2279' \
                   'e7105fd9101c428b94faaeec5e179cf'
    actual_date, actual_sig = @client.send(:sign, 'PoSt', HOST, '/Foo/BaR2/qux', params, body, additional_headers,
                                           options: { date: expected_date })
    assert_equal(expected_sig, actual_sig)
    assert_equal(expected_date, actual_date)
  end
end

class TestRetryRequests < HTTPTestCase
  def test_non_limited_response
    @mock_http.expects(:request).returns(@ok_resp)
    @client.expects(:sleep).never
    actual_resp = @client.request('GET', '/foo/bar')
    assert_equal(@ok_resp, actual_resp)
  end

  def test_single_limited_response
    @mock_http.expects(:request).twice.returns(@ratelimit_resp, @ok_resp)
    @client.expects(:rand).returns(0.123)
    @client.expects(:sleep).with(1.123)
    actual_resp = @client.request('GET', '/foo/bar')
    assert_equal(@ok_resp, actual_resp)
  end

  def test_all_limited_responses
    @mock_http.expects(:request).times(7).returns(@ratelimit_resp)
    @client.expects(:rand).times(6).returns(0.123)
    @client.expects(:sleep).with(1.123)
    @client.expects(:sleep).with(2.123)
    @client.expects(:sleep).with(4.123)
    @client.expects(:sleep).with(8.123)
    @client.expects(:sleep).with(16.123)
    @client.expects(:sleep).with(32.123)
    actual_resp = @client.request('GET', '/foo/bar')
    assert_equal(@ratelimit_resp, actual_resp)
  end
end
