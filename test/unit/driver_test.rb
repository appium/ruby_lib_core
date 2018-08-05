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
      @core.wait { assert File.size?(@core.export_session_path) }
    end

    def test_verify_appium_core_base_capabilities_create_capabilities
      caps = ::Appium::Core::Base::Capabilities.create_capabilities(platformName:    'ios',
                                                                    platformVersion: '10.3',
                                                                    automationName:  'XCUITest',
                                                                    deviceName:      'iPhone Simulator',
                                                                    app:             'test/functional/app/UICatalog.app',
                                                                    some_capability1: 'some_capability1',
                                                                    someCapability2: 'someCapability2')

      caps_with_json = JSON.parse(caps.to_json)
      assert_equal 'ios', caps_with_json['platformName']
      assert_equal '10.3', caps_with_json['platformVersion']
      assert_equal 'test/functional/app/UICatalog.app', caps_with_json['app']
      assert_equal 'XCUITest', caps_with_json['automationName']
      assert_equal 'iPhone Simulator', caps_with_json['deviceName']
      assert_equal 'some_capability1', caps_with_json['someCapability1']
      assert_equal 'someCapability2', caps_with_json['someCapability2']

      assert_equal 'ios', caps[:platformName]
      assert_equal '10.3', caps[:platformVersion]
      assert_equal 'test/functional/app/UICatalog.app', caps[:app]
      assert_equal 'XCUITest', caps[:automationName]
      assert_equal 'iPhone Simulator', caps[:deviceName]
      assert_equal 'some_capability1', caps[:some_capability1]
      assert_equal 'someCapability2', caps[:someCapability2]
    end

    def test_default_wait
      assert_equal 30, @core.default_wait
    end

    def test_default_timeout_for_http_client
      @driver ||= android_mock_create_session

      assert_equal 999_999, @core.http_client.open_timeout
      assert_equal 999_999, @core.http_client.read_timeout
    end

    def test_search_context_in_element_class
      assert_equal 'class name', ::Selenium::WebDriver::Element::FINDERS[:class]
      assert_equal 'class name', ::Selenium::WebDriver::Element::FINDERS[:class_name]
      assert_equal 'css selector', ::Selenium::WebDriver::Element::FINDERS[:css]
      assert_equal 'id', ::Selenium::WebDriver::Element::FINDERS[:id]
      assert_equal 'link text', ::Selenium::WebDriver::Element::FINDERS[:link]
      assert_equal 'link text', ::Selenium::WebDriver::Element::FINDERS[:link_text]
      assert_equal 'name', ::Selenium::WebDriver::Element::FINDERS[:name]
      assert_equal 'partial link text', ::Selenium::WebDriver::Element::FINDERS[:partial_link_text]
      assert_equal 'tag name', ::Selenium::WebDriver::Element::FINDERS[:tag_name]
      assert_equal 'xpath', ::Selenium::WebDriver::Element::FINDERS[:xpath]
      assert_equal 'accessibility id', ::Selenium::WebDriver::Element::FINDERS[:accessibility_id]
      assert_equal '-android uiautomator', ::Selenium::WebDriver::Element::FINDERS[:uiautomator]
      assert_equal '-ios uiautomation', ::Selenium::WebDriver::Element::FINDERS[:uiautomation]
      assert_equal '-ios predicate string', ::Selenium::WebDriver::Element::FINDERS[:predicate]
      assert_equal '-ios class chain', ::Selenium::WebDriver::Element::FINDERS[:class_chain]
      assert_equal '-ios uiautomation', ::Selenium::WebDriver::Element::FINDERS[:uiautomation]
      assert_equal '-ios predicate string', ::Selenium::WebDriver::Element::FINDERS[:predicate]
      assert_equal '-ios class chain', ::Selenium::WebDriver::Element::FINDERS[:class_chain]
      assert_equal '-windows uiautomation', ::Selenium::WebDriver::Element::FINDERS[:windows_uiautomation]
      assert_equal '-tizen uiautomation', ::Selenium::WebDriver::Element::FINDERS[:tizen_uiautomation]
      assert_equal '-image', ::Selenium::WebDriver::Element::FINDERS[:image]
    end
  end
end
