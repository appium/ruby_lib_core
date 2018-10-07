require 'test_helper'

class AppiumLibCoreTest
  class DriverTest < Minitest::Test
    include AppiumLibCoreTest::Mock

    def setup
      @core ||= ::Appium::Core.for(Caps.android)
    end

    class ExampleDriver
      def initialize(opts)
        ::Appium::Core.for(opts)
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

    # https://www.w3.org/TR/webdriver1/
    def test_search_context_in_element_class
      assert_equal 19, ::Selenium::WebDriver::Element::FINDERS.length
      assert_equal({ class: 'class name',
                     class_name: 'class name',
                     css: 'css selector',                    # Defined in W3C spec
                     id: 'id',
                     link: 'link text',                      # Defined in W3C spec
                     link_text: 'link text',                 # Defined in W3C spec
                     name: 'name',
                     partial_link_text: 'partial link text', # Defined in W3C spec
                     tag_name: 'tag name',                   # Defined in W3C spec
                     xpath: 'xpath',                         # Defined in W3C spec
                     accessibility_id: 'accessibility id',
                     image: '-image',
                     uiautomator: '-android uiautomator',
                     viewtag: '-android viewtag', uiautomation: '-ios uiautomation',
                     predicate: '-ios predicate string',
                     class_chain: '-ios class chain',
                     windows_uiautomation: '-windows uiautomation',
                     tizen_uiautomation: '-tizen uiautomation' }, ::Selenium::WebDriver::Element::FINDERS)
    end
  end
end
