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
      caps = ::Appium::Core::Base::Capabilities.create_capabilities(platformName: 'ios',
                                                                    platformVersion: '11.4',
                                                                    automationName: 'XCUITest',
                                                                    deviceName: 'iPhone Simulator',
                                                                    app: 'test/functional/app/UICatalog.app.zip',
                                                                    some_capability1: 'some_capability1',
                                                                    someCapability2: 'someCapability2')

      caps_with_json = JSON.parse(caps.to_json)
      assert_equal 'ios', caps_with_json['platformName']
      assert_equal '11.4', caps_with_json['platformVersion']
      assert_equal 'test/functional/app/UICatalog.app.zip', caps_with_json['app']
      assert_equal 'XCUITest', caps_with_json['automationName']
      assert_equal 'iPhone Simulator', caps_with_json['deviceName']
      assert_equal 'some_capability1', caps_with_json['someCapability1']
      assert_equal 'someCapability2', caps_with_json['someCapability2']

      assert_equal 'ios', caps[:platformName]
      assert_equal '11.4', caps[:platformVersion]
      assert_equal 'test/functional/app/UICatalog.app.zip', caps[:app]
      assert_equal 'XCUITest', caps[:automationName]
      assert_equal 'iPhone Simulator', caps[:deviceName]
      assert_equal 'some_capability1', caps[:some_capability1]
      assert_equal 'someCapability2', caps[:someCapability2]
    end

    def test_default_wait
      assert_equal 0, @core.default_wait
    end

    def test_default_timeout_for_http_client
      @driver ||= android_mock_create_session

      assert_equal 999_999, @core.http_client.open_timeout
      assert_equal 999_999, @core.http_client.read_timeout
      uri = @driver.send(:bridge).http.send(:server_url)
      assert !@core.direct_connect
      assert_equal 'http', uri.scheme
      assert_equal '127.0.0.1', uri.host
      assert_equal 4723, uri.port
      assert_equal '/wd/hub/', uri.path
    end

    def test_default_timeout_for_http_client_with_direct
      def android_mock_create_session_w3c_direct(core)
        response = {
          value: {
            sessionId: '1234567890',
            capabilities: {
              platformName: :android,
              automationName: ENV['AUTOMATION_NAME_DROID'] || 'uiautomator2',
              app: 'test/functional/app/api.apk.zip',
              platformVersion: '7.1.1',
              deviceName: 'Android Emulator',
              appPackage: 'io.appium.android.apis',
              appActivity: 'io.appium.android.apis.ApiDemos',
              someCapability: 'some_capability',
              unicodeKeyboard: true,
              resetKeyboard: true,
              directConnectProtocol: 'http',
              directConnectHost: 'localhost',
              directConnectPort: '8888',
              directConnectPath: '/wd/hub'
            }
          }
        }.to_json

        stub_request(:post, 'http://127.0.0.1:4723/wd/hub/session')
          .to_return(headers: HEADER, status: 200, body: response)

        stub_request(:post, 'http://localhost:8888/wd/hub/session/1234567890/timeouts')
          .with(body: { implicit: 30_000 }.to_json)
          .to_return(headers: HEADER, status: 200, body: { value: nil }.to_json)

        driver = core.start_driver

        assert_requested(:post, 'http://127.0.0.1:4723/wd/hub/session', times: 1)
        assert_requested(:post, 'http://localhost:8888/wd/hub/session/1234567890/timeouts',
                         body: { implicit: 30_000 }.to_json, times: 1)
        driver
      end

      core = ::Appium::Core.for(Caps.android_direct)
      driver = android_mock_create_session_w3c_direct(core)

      assert_equal 999_999, driver.send(:bridge).http.open_timeout
      assert_equal 999_999, driver.send(:bridge).http.read_timeout
      uri = driver.send(:bridge).http.send(:server_url)
      assert core.direct_connect
      assert_equal 'http', uri.scheme
      assert_equal 'localhost', uri.host
      assert_equal 8888, uri.port
      assert_equal '/wd/hub/', uri.path
    end

    def test_default_timeout_for_http_client_with_direct_no_path
      def android_mock_create_session_w3c_direct_no_path(core)
        response = {
          value: {
            sessionId: '1234567890',
            capabilities: {
              platformName: :android,
              automationName: ENV['AUTOMATION_NAME_DROID'] || 'uiautomator2',
              app: 'test/functional/app/api.apk.zip',
              platformVersion: '7.1.1',
              deviceName: 'Android Emulator',
              appPackage: 'io.appium.android.apis',
              appActivity: 'io.appium.android.apis.ApiDemos',
              someCapability: 'some_capability',
              unicodeKeyboard: true,
              resetKeyboard: true,
              directConnectProtocol: 'http',
              directConnectHost: 'localhost',
              directConnectPort: '8888'
            }
          }
        }.to_json

        stub_request(:post, 'http://127.0.0.1:4723/wd/hub/session')
          .to_return(headers: HEADER, status: 200, body: response)

        stub_request(:post, 'http://127.0.0.1:4723/wd/hub/session/1234567890/timeouts')
          .with(body: { implicit: 30_000 }.to_json)
          .to_return(headers: HEADER, status: 200, body: { value: nil }.to_json)

        driver = core.start_driver

        assert_requested(:post, 'http://127.0.0.1:4723/wd/hub/session', times: 1)
        assert_requested(:post, 'http://127.0.0.1:4723/wd/hub/session/1234567890/timeouts',
                         body: { implicit: 30_000 }.to_json, times: 1)
        driver
      end

      core = ::Appium::Core.for(Caps.android_direct)
      driver = android_mock_create_session_w3c_direct_no_path(core)

      assert_equal 999_999, driver.send(:bridge).http.open_timeout
      assert_equal 999_999, driver.send(:bridge).http.read_timeout
      uri = driver.send(:bridge).http.send(:server_url)
      assert core.direct_connect
      assert_equal 'http', uri.scheme
      assert_equal '127.0.0.1', uri.host
      assert_equal 4723, uri.port
      assert_equal '/wd/hub/', uri.path
    end

    # https://www.w3.org/TR/webdriver1/
    def test_search_context_in_element_class
      assert_equal 21, ::Selenium::WebDriver::Element::FINDERS.length
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
                     custom: '-custom',
                     uiautomator: '-android uiautomator',
                     viewtag: '-android viewtag',
                     data_matcher: '-android datamatcher',
                     uiautomation: '-ios uiautomation',
                     predicate: '-ios predicate string',
                     class_chain: '-ios class chain',
                     windows_uiautomation: '-windows uiautomation',
                     tizen_uiautomation: '-tizen uiautomation' }, ::Selenium::WebDriver::Element::FINDERS)
    end
  end
end
