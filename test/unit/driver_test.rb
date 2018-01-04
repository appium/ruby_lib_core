require 'test_helper'

class AppiumLibCoreTest
  class DriverTest < Minitest::Test
    include AppiumLibCoreTest::Mock

    def setup
      @core ||= ::Appium::Core.for(self, Caps::ANDROID_OPS)
    end

    class ExampleDriver
      def initialize(opts)
        ::Appium::Core.for(self, opts)
      end
    end

    def test_no_caps
      opts = { no: { caps: {} }, appium_lib: {} }

      assert_raises ::Appium::Core::Error::NoCapabilityError do
        ExampleDriver.new(opts)
      end
    end

    def test_with_caps
      opts = { caps: {} }
      refute_nil ExampleDriver.new(opts)
    end

    def test_with_caps_and_appium_lib
      opts = { caps: {}, appium_lib: {} }
      refute_nil ExampleDriver.new(opts)
    end

    def test_with_caps_and_wrong_appium_lib
      opts = { caps: { appium_lib: {} } }
      assert_raises ::Appium::Core::Error::CapabilityStructureError do
        ExampleDriver.new(opts)
      end
    end

    def test_verify_session_id_in_the_export_session_path
      assert_equal '1234567890', File.read(@core.export_session_path).strip
    end

    def test_verify_session_from_default_value
      assert_equal '1234567890', File.read('/tmp/appium_lib_session').strip
    end

    def test_verify_appium_core_base_capabilities_create_capabilities
      caps = ::Appium::Core::Base::Capabilities.create_capabilities(platformName:    'ios',
                                                                    platformVersion: '10.3',
                                                                    automationName:  'XCUITest',
                                                                    deviceName:      'iPhone Simulator',
                                                                    app:             'test/functional/app/UICatalog.app',
                                                                    some_capability: 'some_capability')

      caps_with_json = JSON.parse(caps.to_json)
      assert_equal 'ios', caps_with_json['platformName']
      assert_equal '10.3', caps_with_json['platformVersion']
      assert_equal 'test/functional/app/UICatalog.app', caps_with_json['app']
      assert_equal 'XCUITest', caps_with_json['automationName']
      assert_equal 'iPhone Simulator', caps_with_json['deviceName']
      assert_equal 'some_capability', caps_with_json['someCapability']

      assert_equal 'ios', caps[:platformName]
      assert_equal '10.3', caps[:platformVersion]
      assert_equal 'test/functional/app/UICatalog.app', caps[:app]
      assert_equal 'XCUITest', caps[:automationName]
      assert_equal 'iPhone Simulator', caps[:deviceName]
      assert_equal 'some_capability', caps[:some_capability]
    end

    def test_default_wait
      assert_equal 30, @core.default_wait
    end

    def test_default_timeout_for_http_client
      @driver ||= android_mock_create_session

      assert_equal 999_999, @core.http_client.open_timeout
      assert_equal 999_999, @core.http_client.read_timeout
    end
  end
end
