require 'test_helper'

class AppiumLibCoreTest
  class RootTest < Minitest::Test
    def test_version
      assert !::Appium::Core::VERSION.nil?
    end

    def test_symbolize_keys
      result = ::Appium.symbolize_keys({ 'a' => 1, b: 2 })
      assert_equal({ a: 1, b: 2 }, result)
    end

    def test_symbolize_keys_nested
      result = ::Appium.symbolize_keys({ 'a' => 1, b: { 'c' => 2, d: 3 } })
      assert_equal({ a: 1, b: { c: 2, d: 3 } }, result)
    end

    def test_symbolize_keys_raise_argument_error
      e = assert_raises ArgumentError do
        ::Appium.symbolize_keys('no hash value')
      end

      assert_equal 'symbolize_keys requires a hash', e.message
    end

    def test_url_param
      opts = {
        url: 'http://custom-host:8080/wd/hub.com',
        caps: {
          platformName: :ios,
          platformVersion: '11.0',
          deviceName: 'iPhone Simulator',
          automationName: 'XCUITest',
          app: '/path/to/MyiOS.app'
        }
      }
      @core = Appium::Core.for(opts) # create a core driver with `opts` and extend methods into `self`
      assert_equal 'http://custom-host:8080/wd/hub.com', @core.custom_url
    end

    def test_url_server_url
      opts = {
        desired_capabilities: {
          platformName: :ios,
          platformVersion: '11.0',
          deviceName: 'iPhone Simulator',
          automationName: 'XCUITest',
          app: '/path/to/MyiOS.app'
        },
        appium_lib: {
          server_url: 'http://custom-host:8080/wd/hub.com'
        }
      }
      @core = Appium::Core.for(opts) # create a core driver with `opts` and extend methods into `self`
      assert_equal 'http://custom-host:8080/wd/hub.com', @core.custom_url
    end

    def test_url_is_prior_than_server_url
      opts = {
        url: 'http://custom-host1:8080/wd/hub.com',
        caps: {
          platformName: :ios,
          platformVersion: '11.0',
          deviceName: 'iPhone Simulator',
          automationName: 'XCUITest',
          app: '/path/to/MyiOS.app'
        },
        appium_lib: {
          server_url: 'http://custom-host2:8080/wd/hub.com'
        }
      }
      @core = Appium::Core.for(opts) # create a core driver with `opts` and extend methods into `self`
      assert_equal 'http://custom-host1:8080/wd/hub.com', @core.custom_url
    end
  end
end
