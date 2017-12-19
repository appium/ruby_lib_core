require 'test_helper'

# $ rake test:unit TEST=test/unit/common_test.rb
class AppiumLibCoreTest
  class Common
    class AppiumCoreBaseBridgeTest < Minitest::Test
      def setup
        @bridge = Appium::Core::Base::Bridge.new
      end

      def test_add_appium_prefix_compatible_with_oss
        cap = {
          platformName: :ios,
          automationName: 'XCUITest',
          app: 'test/functional/app/UICatalog.app',
          platformVersion: '10.3',
          deviceName: 'iPhone Simulator',
          useNewWDA: true,
          some_capability: 'some_capability'
        }
        base_caps = Appium::Core::Base::Capabilities.create_capabilities(cap)

        expected = {
          proxy: nil,
          platformName: :ios,
          'appium:automationName' => 'XCUITest',
          'appium:app' => 'test/functional/app/UICatalog.app',
          'appium:platformVersion' => '10.3',
          'appium:deviceName' => 'iPhone Simulator',
          'appium:useNewWDA' => true,
          'appium:some_capability' => 'some_capability'
        }

        assert_equal expected, @bridge.add_appium_prefix(base_caps).__send__(:capabilities)
      end

      def test_add_appium_prefix_already_have_appium_prefix
        cap = {
          platformName: :ios,
          automationName: 'XCUITest',
          'appium:app' => 'test/functional/app/UICatalog.app',
          platformVersion: '10.3',
          deviceName: 'iPhone Simulator',
          useNewWDA: true,
          some_capability: 'some_capability'
        }
        base_caps = Appium::Core::Base::Capabilities.create_capabilities(cap)

        expected = {
          proxy: nil,
          platformName: :ios,
          'appium:automationName' => 'XCUITest',
          'appium:app' => 'test/functional/app/UICatalog.app',
          'appium:platformVersion' => '10.3',
          'appium:deviceName' => 'iPhone Simulator',
          'appium:useNewWDA' => true,
          'appium:some_capability' => 'some_capability'
        }

        assert_equal expected, @bridge.add_appium_prefix(base_caps).__send__(:capabilities)
      end

      def test_add_appium_prefix_has_no_parameter
        cap = {}
        base_caps = Appium::Core::Base::Capabilities.create_capabilities(cap)
        expected = { proxy: nil }

        assert_equal expected, @bridge.add_appium_prefix(base_caps).__send__(:capabilities)
      end
    end
  end
end
