# frozen_string_literal: true

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'test_helper'

class AppiumLibCoreTest
  class DriverTest < Minitest::Test
    include AppiumLibCoreTest::Mock

    def setup
      @core ||= ::Appium::Core.for(Caps.android)
    end

    class ExampleDriver
      # for test
      attr_reader :core

      def initialize(opts)
        @core = ::Appium::Core.for(opts)
      end
    end

    def test_with_caps
      opts = { caps: { automationName: 'xcuitest' } }
      driver = ExampleDriver.new(opts)
      refute_nil driver
      assert_equal driver.core.caps[:automationName], 'xcuitest'
    end

    def test_with_capabilities
      opts = { capabilities: { automationName: 'xcuitest' } }
      driver = ExampleDriver.new(opts)
      refute_nil driver
      assert_equal driver.core.caps[:automationName], 'xcuitest'
    end

    def test_with_caps_and_appium_lib
      opts = { 'caps' => { 'automationName': 'xcuitest' }, appium_lib: {} }
      driver = ExampleDriver.new(opts)
      refute_nil driver
      assert_equal driver.core.caps[:automationName], 'xcuitest'
    end

    def test_verify_appium_core_base_capabilities_create_capabilities
      caps = ::Appium::Core::Base::Capabilities.new(platformName: 'ios',
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
      assert_equal 5, @core.default_wait
    end

    def test_default_timeout_for_http_client
      @driver ||= android_mock_create_session

      assert_equal 999_999, @core.http_client.open_timeout
      assert_equal 999_999, @core.http_client.read_timeout
      uri = @driver.send(:bridge).http.send(:server_url)
      assert @core.direct_connect
      assert_equal 'http', uri.scheme
      assert_equal '127.0.0.1', uri.host
      assert_equal 4723, uri.port
      assert_equal '/wd/hub/', uri.path
    end

    def test_http_client
      client = ::Appium::Core::Base::Http::Default.new
      assert client.instance_variable_defined? :@extra_headers
    end

    def test_default_timeout_for_http_client_with_direct
      android_mock_create_session_w3c_direct = lambda do |core|
        response = {
          value: {
            sessionId: '1234567890',
            capabilities: {
              platformName: :android,
              automationName: ENV['APPIUM_DRIVER'] || 'uiautomator2',
              app: 'test/functional/app/api.apk.zip',
              platformVersion: '7.1.1',
              deviceName: 'Android Emulator',
              appPackage: 'io.appium.android.apis',
              appActivity: 'io.appium.android.apis.ApiDemos',
              someCapability: 'some_capability',
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
      driver = android_mock_create_session_w3c_direct.call(core)

      assert_equal 999_999, driver.send(:bridge).http.open_timeout
      assert_equal 999_999, driver.send(:bridge).http.read_timeout
      uri = driver.send(:bridge).http.send(:server_url)
      assert core.direct_connect
      assert_equal 'http', uri.scheme
      assert_equal 'localhost', uri.host
      assert_equal 8888, uri.port
      assert_equal '/wd/hub/', uri.path
    end

    def test_default_timeout_for_http_client_with_direct_appium_prefix
      android_mock_create_session_w3c_direct = lambda do |core|
        response = {
          value: {
            sessionId: '1234567890',
            capabilities: {
              platformName: :android,
              automationName: ENV['APPIUM_DRIVER'] || 'uiautomator2',
              app: 'test/functional/app/api.apk.zip',
              platformVersion: '7.1.1',
              deviceName: 'Android Emulator',
              appPackage: 'io.appium.android.apis',
              appActivity: 'io.appium.android.apis.ApiDemos',
              someCapability: 'some_capability',
              'appium:directConnectProtocol' => 'http',
              'appium:directConnectHost' => 'localhost',
              'appium:directConnectPort' => '8888',
              'appium:directConnectPath' => '/wd/hub'
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
      driver = android_mock_create_session_w3c_direct.call(core)

      assert_equal 999_999, driver.send(:bridge).http.open_timeout
      assert_equal 999_999, driver.send(:bridge).http.read_timeout
      uri = driver.send(:bridge).http.send(:server_url)
      assert core.direct_connect
      assert_equal 'http', uri.scheme
      assert_equal 'localhost', uri.host
      assert_equal 8888, uri.port
      assert_equal '/wd/hub/', uri.path
    end

    def test_default_timeout_for_http_client_with_direct_appium_prefix_prior_than_non_prefix
      android_mock_create_session_w3c_direct = lambda do |core|
        response = {
          value: {
            sessionId: '1234567890',
            capabilities: {
              platformName: :android,
              automationName: ENV['APPIUM_DRIVER'] || 'uiautomator2',
              app: 'test/functional/app/api.apk.zip',
              platformVersion: '7.1.1',
              deviceName: 'Android Emulator',
              appPackage: 'io.appium.android.apis',
              appActivity: 'io.appium.android.apis.ApiDemos',
              someCapability: 'some_capability',
              'appium:directConnectProtocol' => 'http',
              'appium:directConnectHost' => 'localhost',
              'appium:directConnectPort' => '8888',
              'appium:directConnectPath' => '/wd/hub',
              directConnectProtocol: 'https',
              directConnectHost: 'non-appium-localhost',
              directConnectPort: '8889',
              directConnectPath: '/non/appium/wd/hub'
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
      driver = android_mock_create_session_w3c_direct.call(core)

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
      android_mock_create_session_w3c_direct_no_path = lambda do |core|
        response = {
          value: {
            sessionId: '1234567890',
            capabilities: {
              platformName: :android,
              automationName: ENV['APPIUM_DRIVER'] || 'uiautomator2',
              app: 'test/functional/app/api.apk.zip',
              platformVersion: '7.1.1',
              deviceName: 'Android Emulator',
              appPackage: 'io.appium.android.apis',
              appActivity: 'io.appium.android.apis.ApiDemos',
              someCapability: 'some_capability',
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
      driver = android_mock_create_session_w3c_direct_no_path.call(core)

      assert_equal 999_999, driver.send(:bridge).http.open_timeout
      assert_equal 999_999, driver.send(:bridge).http.read_timeout
      uri = driver.send(:bridge).http.send(:server_url)
      assert core.direct_connect
      assert_equal 'http', uri.scheme
      assert_equal '127.0.0.1', uri.host
      assert_equal 4723, uri.port
      assert_equal '/wd/hub/', uri.path
    end

    def test_default_timeout_for_http_client_with_direct_no_supported_client
      android_mock_create_session_w3c_direct_default_client = lambda do |core|
        response = {
          value: {
            sessionId: '1234567890',
            capabilities: {
              platformName: :android,
              automationName: ENV['APPIUM_DRIVER'] || 'uiautomator2',
              app: 'test/functional/app/api.apk.zip',
              platformVersion: '7.1.1',
              deviceName: 'Android Emulator',
              appPackage: 'io.appium.android.apis',
              appActivity: 'io.appium.android.apis.ApiDemos',
              someCapability: 'some_capability',
              directConnectProtocol: 'http',
              directConnectHost: 'localhost',
              directConnectPort: '8888',
              directConnectPath: '/wd/hub'
            }
          }
        }.to_json

        stub_request(:post, 'http://127.0.0.1:4723/wd/hub/session')
          .to_return(headers: HEADER, status: 200, body: response)

        stub_request(:post, 'http://127.0.0.1:4723/wd/hub/session/1234567890/timeouts')
          .with(body: { implicit: 30_000 }.to_json)
          .to_return(headers: HEADER, status: 200, body: { value: nil }.to_json)

        driver = core.start_driver http_client_ops: { http_client: Selenium::WebDriver::Remote::Http::Default.new }

        assert_requested(:post, 'http://127.0.0.1:4723/wd/hub/session', times: 1)
        assert_requested(:post, 'http://127.0.0.1:4723/wd/hub/session/1234567890/timeouts',
                         body: { implicit: 30_000 }.to_json, times: 1)
        driver
      end

      core = ::Appium::Core.for(Caps.android_direct)
      driver = android_mock_create_session_w3c_direct_default_client.call(core)

      assert_nil driver.send(:bridge).http.open_timeout
      assert_nil driver.send(:bridge).http.read_timeout
      uri = driver.send(:bridge).http.send(:server_url)
      assert core.direct_connect
      assert_equal 'http', uri.scheme
      assert_equal '127.0.0.1', uri.host
      assert_equal 4723, uri.port
      assert_equal '/wd/hub/', uri.path
    end

    def test_default_timeout_for_http_client_with_enable_idempotency_header_false
      def _android_mock_create_session_w3c(core)
        response = {
          value: {
            sessionId: '1234567890',
            capabilities: {
              platformName: :android,
              automationName: ENV['APPIUM_DRIVER'] || 'uiautomator2',
              app: 'test/functional/app/api.apk.zip',
              platformVersion: '7.1.1',
              deviceName: 'Android Emulator',
              appPackage: 'io.appium.android.apis',
              appActivity: 'io.appium.android.apis.ApiDemos',
              someCapability: 'some_capability'
            }
          }
        }.to_json

        stub_request(:post, 'http://127.0.0.1:4723/wd/hub/session')
          .to_return(headers: HEADER, status: 200, body: response)

        stub_request(:post, 'http://127.0.0.1:4723/wd/hub/session/1234567890/timeouts')
          .with(body: { implicit: 5_000 }.to_json)
          .to_return(headers: HEADER, status: 200, body: { value: nil }.to_json)

        driver = core.start_driver

        assert_requested(:post, 'http://127.0.0.1:4723/wd/hub/session', times: 1)
        assert_requested(:post, 'http://127.0.0.1:4723/wd/hub/session/1234567890/timeouts',
                         body: { implicit: 5_000 }.to_json, times: 1)
        driver
      end

      caps = Caps.android
      caps[:appium_lib][:enable_idempotency_header] = false
      core = ::Appium::Core.for(caps)
      driver = _android_mock_create_session_w3c(core)

      assert driver.send(:bridge).http.is_a?(::Appium::Core::Base::Http::Default)
      assert_equal({}, driver.send(:bridge).http.extra_headers)
      assert_equal 999_999, driver.send(:bridge).http.open_timeout
      assert_equal 999_999, driver.send(:bridge).http.read_timeout
    end

    def test_default_timeout_for_http_client_with_custom_http_client
      def _android_mock_create_session_w3c_with_custom_http_client(core)
        response = {
          value: {
            sessionId: '1234567890',
            capabilities: {
              platformName: :android,
              automationName: ENV['APPIUM_DRIVER'] || 'uiautomator2',
              app: 'test/functional/app/api.apk.zip',
              platformVersion: '7.1.1',
              deviceName: 'Android Emulator',
              appPackage: 'io.appium.android.apis',
              appActivity: 'io.appium.android.apis.ApiDemos',
              someCapability: 'some_capability'
            }
          }
        }.to_json

        stub_request(:post, 'http://127.0.0.1:4723/wd/hub/session')
          .to_return(headers: HEADER, status: 200, body: response)

        stub_request(:post, 'http://127.0.0.1:4723/wd/hub/session/1234567890/timeouts')
          .with(body: { implicit: 5_000 }.to_json)
          .to_return(headers: HEADER, status: 200, body: { value: nil }.to_json)

        driver = core.start_driver http_client_ops: { http_client: Selenium::WebDriver::Remote::Http::Default.new }

        assert_requested(:post, 'http://127.0.0.1:4723/wd/hub/session', times: 1)
        assert_requested(:post, 'http://127.0.0.1:4723/wd/hub/session/1234567890/timeouts',
                         body: { implicit: 5_000 }.to_json, times: 1)
        driver
      end

      caps = Caps.android
      core = ::Appium::Core.for(caps)
      driver = _android_mock_create_session_w3c_with_custom_http_client(core)

      # No @extra_headers case
      assert driver.send(:bridge).http.is_a?(::Selenium::WebDriver::Remote::Http::Default)
      assert_equal(false, driver.send(:bridge).http.instance_variable_defined?(:@extra_headers))
    end

    # https://www.w3.org/TR/webdriver1/
    def test_search_context_in_element_class
      assert_equal(
        {
          class: 'class name',
          class_name: 'class name',
          css: 'css selector',                    # Defined in W3C spec
          id: 'id',
          link: 'link text',                      # Defined in W3C spec
          link_text: 'link text',                 # Defined in W3C spec
          name: 'name',
          partial_link_text: 'partial link text', # Defined in W3C spec
          relative: 'relative',                   # Defined in Selenium
          tag_name: 'tag name',                   # Defined in W3C spec
          xpath: 'xpath',                         # Defined in W3C spec
          accessibility_id: 'accessibility id',
          image: '-image',
          custom: '-custom',
          uiautomator: '-android uiautomator',
          viewtag: '-android viewtag',
          data_matcher: '-android datamatcher',
          view_matcher: '-android viewmatcher',
          predicate: '-ios predicate string',
          class_chain: '-ios class chain'
        },
        ::Appium::Core::Element::FINDERS.merge(::Selenium::WebDriver::SearchContext.extra_finders)
      )
    end

    def test_attach_to_an_existing_session
      android_mock_create_session_w3c_direct = lambda do |core|
        response = {
          value: {
            sessionId: '1234567890',
            capabilities: {
              platformName: :android,
              automationName: ENV['APPIUM_DRIVER'] || 'uiautomator2',
              app: 'test/functional/app/api.apk.zip',
              platformVersion: '7.1.1',
              deviceName: 'Android Emulator',
              appPackage: 'io.appium.android.apis',
              appActivity: 'io.appium.android.apis.ApiDemos',
              someCapability: 'some_capability',
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
      driver = android_mock_create_session_w3c_direct.call(core)

      attached_driver = ::Appium::Core::Driver.attach_to(
        driver.session_id,
        url: 'http://127.0.0.1:4723/wd/hub', automation_name: 'UiAutomator2', platform_name: 'Android'
      )

      assert_equal driver.session_id, attached_driver.session_id
      # base session
      assert driver.respond_to?(:current_activity)
      assert_equal driver.capabilities['automationName'], ENV['APPIUM_DRIVER'] || 'uiautomator2'

      # to check the extend_for if the new driver instance also has the expected method for Android
      assert attached_driver.respond_to?(:current_activity)
      assert_equal attached_driver.capabilities['automationName'], 'UiAutomator2'
    end

    def test_listener_default
      android_mock_create_session_w3c_direct = lambda do |core|
        response = {
          value: {
            sessionId: '1234567890',
            capabilities: {
              platformName: :android,
              automationName: ENV['APPIUM_DRIVER'] || 'uiautomator2',
              deviceName: 'Android Emulator'
            }
          }
        }.to_json

        stub_request(:post, 'http://127.0.0.1:4723/wd/hub/session')
          .to_return(headers: HEADER, status: 200, body: response)

        driver = core.start_driver

        assert_requested(:post, 'http://127.0.0.1:4723/wd/hub/session', times: 1)
        driver
      end

      core = ::Appium::Core.for capabilities: Caps.android[:capabilities]
      assert_nil core.listener
      driver = android_mock_create_session_w3c_direct.call(core)

      assert_equal driver.send(:bridge).class, Appium::Core::Base::Bridge
      assert_equal driver.instance_variable_get(:@wait_timeout), 30
      assert !driver.send(:bridge).respond_to?(:driver)
    end

    def test_listener_with_custom_listener_element
      custom_listener = ::Selenium::WebDriver::Support::AbstractEventListener.new

      android_mock_create_session_w3c_direct = lambda do |core|
        response = {
          value: {
            sessionId: '1234567890',
            capabilities: {
              platformName: :android,
              automationName: ENV['APPIUM_DRIVER'] || 'uiautomator2',
              deviceName: 'Android Emulator'
            }
          }
        }.to_json

        stub_request(:post, 'http://127.0.0.1:4723/wd/hub/session')
          .to_return(headers: HEADER, status: 200, body: response)

        driver = core.start_driver

        assert_requested(:post, 'http://127.0.0.1:4723/wd/hub/session', times: 1)
        driver
      end

      core = ::Appium::Core.for capabilities: Caps.android[:capabilities], appium_lib: {
        wait_timeout: 500, listener: custom_listener
      }
      driver = android_mock_create_session_w3c_direct.call(core)

      assert_equal core.listener, custom_listener
      assert_equal driver.send(:bridge).class, Appium::Support::EventFiringBridge
      assert_equal driver.send(:bridge).send(:driver).class, Appium::Core::Base::Driver
      assert_equal driver.send(:bridge).send(:driver).instance_variable_get(:@wait_timeout), 500
      # To check if the 'driver' instance has the Android specific method
      assert driver.send(:bridge).send(:driver).respond_to? :current_activity
    end

    def test_listener_with_custom_listener_elements
      custom_listener = ::Selenium::WebDriver::Support::AbstractEventListener.new

      android_mock_create_session_w3c_direct = lambda do |core|
        response = {
          value: {
            sessionId: '1234567890',
            capabilities: {
              platformName: :android,
              automationName: ENV['APPIUM_DRIVER'] || 'uiautomator2',
              deviceName: 'Android Emulator'
            }
          }
        }.to_json

        stub_request(:post, 'http://127.0.0.1:4723/wd/hub/session')
          .to_return(headers: HEADER, status: 200, body: response)

        driver = core.start_driver

        assert_requested(:post, 'http://127.0.0.1:4723/wd/hub/session', times: 1)
        driver
      end

      core = ::Appium::Core.for capabilities: Caps.android[:capabilities], appium_lib: {
        wait_timeout: 500, listener: custom_listener
      }
      driver = android_mock_create_session_w3c_direct.call(core)

      # element
      stub_request(:post, "#{SESSION}/element")
        .with(body: { using: 'id', value: 'example' }.to_json)
        .to_return(headers: HEADER, status: 200, body: {
          value: { ELEMENT: 'element_id_parent' }, sessionId: SESSION, status: 0
        }.to_json)
      el = driver.find_element id: 'example'
      assert_requested :post, "#{SESSION}/element", times: 1
      assert_equal el.class.name, 'Appium::Core::Element'

      # No W3C, but can call via '::Appium::Core::Element'
      stub_request(:get, "#{SESSION}/element/element_id_parent/displayed")
        .to_return(headers: HEADER, status: 200, body: { value: {} }.to_json)
      el.displayed?
      assert_requested :get, "#{SESSION}/element/element_id_parent/displayed", times: 1
      assert_equal el.class.name, 'Appium::Core::Element'

      stub_request(:post, "#{SESSION}/element/element_id_parent/element")
        .with(body: { using: 'id', value: 'example2' }.to_json)
        .to_return(headers: HEADER, status: 200, body: {
          value: { ELEMENT: 'element_id_children' }, sessionId: SESSION, status: 0
        }.to_json)
      c_el = el.find_element id: 'example2'
      assert_requested :post, "#{SESSION}/element/element_id_parent/element", times: 1
      assert_equal c_el.class.name, 'Appium::Core::Element'

      # elements
      stub_request(:post, "#{SESSION}/elements")
        .with(body: { using: 'id', value: 'example' }.to_json)
        .to_return(headers: HEADER, status: 200, body: {
          value: [{ ELEMENT: 'element_id_parent' }], sessionId: SESSION, status: 0
        }.to_json)
      els = driver.find_elements id: 'example'
      assert_requested :post, "#{SESSION}/element", times: 1
      assert_equal els.first.class.name, 'Appium::Core::Element'

      stub_request(:post, "#{SESSION}/element/element_id_parent/elements")
        .with(body: { using: 'id', value: 'example2' }.to_json)
        .to_return(headers: HEADER, status: 200, body: { value: [{ ELEMENT: 'element_id_children' }],
                                                          sessionId: SESSION, status: 0 }.to_json)
      c_el = els.first.find_elements id: 'example2'
      assert_requested :post, "#{SESSION}/element/element_id_parent/elements", times: 1
      assert_equal c_el.first.class.name, 'Appium::Core::Element'
    end
  end
end
