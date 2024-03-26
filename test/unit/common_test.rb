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
require 'webmock/minitest'

# $ rake test:unit TEST=test/unit/common_test.rb
class AppiumLibCoreTest
  class Common
    class AppiumCoreBaseBridgeTest < Minitest::Test
      include AppiumLibCoreTest::Mock

      def setup
        @bridge = Appium::Core::Base::Bridge.new url: 'http://127.0.0.1:4723/wd/hub'
      end

      RESPONSE_BASE_VALUE = {
        sessionId: '1234567890',
        capabilities: {
          platformName: :android,
          automationName: 'uiautomator2',
          app: 'test/functional/app/api.apk.zip',
          platformVersion: '7.1.1',
          deviceName: 'Android Emulator',
          appPackage: 'io.appium.android.apis'
        }
      }.freeze

      CAPS = {
        platformName: :android,
        automationName: 'uiautomator2',
        app: "#{Dir.pwd}/test/functional/app/api.apk.zip",
        platformVersion: '7.1.1',
        deviceName: 'Android Emulator',
        'appPackage' => 'io.appium.android.apis',
        'custom_cap' => 'custom_value',
        'custom_cap_2' => {
          'custom_nested_key' => 'custom_value'
        },
        'custom_cap_3' => {
          'custom_nested_key_2' => {
            'custom_nested_key_3' => 'custom_value'
          }
        }
      }.freeze

      APPIUM_PREFIX_CAPS = {
        platformName: :android,
        'appium:automationName' => 'uiautomator2',
        'appium:app' => "#{Dir.pwd}/test/functional/app/api.apk.zip",
        'appium:platformVersion' => '7.1.1',
        'appium:deviceName' => 'Android Emulator',
        'appium:appPackage' => 'io.appium.android.apis',
        'appium:custom_cap' => 'custom_value',
        'appium:custom_cap_2' => {
          'custom_nested_key' => 'custom_value'
        },
        'appium:custom_cap_3' => {
          'custom_nested_key_2' => {
            'custom_nested_key_3' => 'custom_value'
          }
        }
      }.freeze

      def test_create_session_w3c
        response = { value: RESPONSE_BASE_VALUE }.to_json

        stub_request(:post, 'http://127.0.0.1:4723/wd/hub/session')
          .with(body: { capabilities: { alwaysMatch: APPIUM_PREFIX_CAPS, firstMatch: [{}] } }.to_json)
          .to_return(headers: Mock::HEADER, status: 200, body: response)

        _driver = ::Appium::Core.for({ caps: CAPS, appium_lib: {} }).start_driver

        assert_requested(:post, 'http://127.0.0.1:4723/wd/hub/session', times: 1)
      end

      def test_create_session_w3c_with_http_package
        response = {
          value: {
            sessionId: '1234567890',
            capabilities: {
              platformName: :android,
              automationName: 'uiautomator2',
              app: 'http://example.com/test.apk.zip',
              platformVersion: '7.1.1',
              deviceName: 'Android Emulator',
              appPackage: 'io.appium.android.apis'
            }
          }
        }.to_json

        http_caps = {
          platformName: :android,
          automationName: 'uiautomator2',
          app: 'http://example.com/test.apk.zip',
          platformVersion: '7.1.1',
          deviceName: 'Android Emulator',
          appPackage: 'io.appium.android.apis'
        }

        appium_prefix_http_caps = {
          platformName: :android,
          'appium:automationName' => 'uiautomator2',
          'appium:app' => 'http://example.com/test.apk.zip',
          'appium:platformVersion' => '7.1.1',
          'appium:deviceName' => 'Android Emulator',
          'appium:appPackage' => 'io.appium.android.apis'
        }

        stub_request(:post, 'http://127.0.0.1:4723/wd/hub/session')
          .with(body: { capabilities: { alwaysMatch: appium_prefix_http_caps, firstMatch: [{}] } }.to_json)
          .to_return(headers: Mock::HEADER, status: 200, body: response)

        core = ::Appium::Core.for({ caps: http_caps, appium_lib: {} })
        core.start_driver

        assert_requested(:post, 'http://127.0.0.1:4723/wd/hub/session', times: 1)

        assert_equal 'http://example.com/test.apk.zip', core.caps[:app]
      end

      def test_add_appium_prefix_already_have_appium_prefix
        cap = {
          platformName: :ios,
          automationName: 'XCUITest',
          'appium:app' => 'test/functional/app/UICatalog.app.zip',
          platformVersion: '11.4',
          deviceName: 'iPhone Simulator',
          useNewWDA: true,
          some_capability1: 'some_capability1',
          someCapability2: '',
          'some_capability3' => 'string_shold_keep',
          'some_capability4' => {
            'nested_key1' => 1,
            nested_key2: 2
          }
        }
        base_caps = Appium::Core::Base::Capabilities.new cap

        assert_equal base_caps[:platformName], :ios
        assert_nil base_caps['platformName']

        expected = {
          'platformName' => :ios,
          'automationName' => 'XCUITest',
          'appium:app' => 'test/functional/app/UICatalog.app.zip',
          'platformVersion' => '11.4',
          'deviceName' => 'iPhone Simulator',
          'useNewWDA' => true,
          'someCapability1' => 'some_capability1',
          'someCapability2' => '',
          'some_capability3' => 'string_shold_keep',
          'some_capability4' => { 'nested_key1' => 1, 'nestedKey2' => 2 }
        }
        assert_equal expected, base_caps.as_json

        caps_with_appium = @bridge.add_appium_prefix(base_caps)

        expected = {
          platformName: :ios,
          'appium:automationName' => 'XCUITest',
          'appium:app' => 'test/functional/app/UICatalog.app.zip',
          'appium:platformVersion' => '11.4',
          'appium:deviceName' => 'iPhone Simulator',
          'appium:useNewWDA' => true,
          'appium:some_capability1' => 'some_capability1',
          'appium:someCapability2' => '',
          'appium:some_capability3' => 'string_shold_keep',
          'appium:some_capability4' => {
            'nested_key1' => 1,
            nested_key2: 2
          }
        }
        assert_equal expected, caps_with_appium.__send__(:capabilities)

        expected = {
          'platformName' => :ios,
          'appium:automationName' => 'XCUITest',
          'appium:app' => 'test/functional/app/UICatalog.app.zip',
          'appium:platformVersion' => '11.4',
          'appium:deviceName' => 'iPhone Simulator',
          'appium:useNewWDA' => true,
          'appium:some_capability1' => 'some_capability1',
          'appium:someCapability2' => '',
          'appium:some_capability3' => 'string_shold_keep',
          'appium:some_capability4' => {
            'nested_key1' => 1,
            'nestedKey2' => 2
          }
        }
        # for testing
        assert_equal expected, caps_with_appium.as_json
      end

      def test_add_appium_prefix_has_no_parameter
        cap = {}
        base_caps = Appium::Core::Base::Capabilities.new cap
        expected = {}

        assert_equal expected, @bridge.add_appium_prefix(base_caps).__send__(:capabilities)
      end
    end
  end
end
