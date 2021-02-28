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
        appPackage: 'io.appium.android.apis'
      }.freeze

      APPIUM_PREFIX_CAPS = {
        platformName: :android,
        'appium:automationName' => 'uiautomator2',
        'appium:app' => "#{Dir.pwd}/test/functional/app/api.apk.zip",
        'appium:platformVersion' => '7.1.1',
        'appium:deviceName' => 'Android Emulator',
        'appium:appPackage' => 'io.appium.android.apis'
      }.freeze

      def test_create_session_w3c
        response = { value: RESPONSE_BASE_VALUE }.to_json

        stub_request(:post, 'http://127.0.0.1:4723/wd/hub/session')
          .with(body: { capabilities: { firstMatch: [APPIUM_PREFIX_CAPS] } }.to_json)
          .to_return(headers: Mock::HEADER, status: 200, body: response)

        stub_request(:post, "#{Mock::SESSION}/timeouts")
          .with(body: { implicit: 0 }.to_json)
          .to_return(headers: Mock::HEADER, status: 200, body: { value: nil }.to_json)

        stub_request(:get, 'http://127.0.0.1:4723/wd/hub/sessions')
          .to_return(headers: Mock::HEADER, status: 200, body: { value: [{ id: 'c363add8-a7ca-4455-b9e3-9ac4d69e95b3',
                                                                           capabilities: CAPS }] }.to_json)

        driver = ::Appium::Core.for({ caps: CAPS, appium_lib: {} }).start_driver

        assert_requested(:post, 'http://127.0.0.1:4723/wd/hub/session', times: 1)
        assert_requested(:post, "#{Mock::SESSION}/timeouts", body: { implicit: 0 }.to_json, times: 1)

        sessions = driver.sessions
        assert_requested(:get, 'http://127.0.0.1:4723/wd/hub/sessions', times: 1)
        assert_equal 1, sessions.length
        assert_equal 'c363add8-a7ca-4455-b9e3-9ac4d69e95b3', sessions.first['id']
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
          .with(body: { capabilities: { firstMatch: [appium_prefix_http_caps] } }.to_json)
          .to_return(headers: Mock::HEADER, status: 200, body: response)

        stub_request(:post, "#{Mock::SESSION}/timeouts")
          .with(body: { implicit: 0 }.to_json)
          .to_return(headers: Mock::HEADER, status: 200, body: { value: nil }.to_json)

        core = ::Appium::Core.for({ caps: http_caps, appium_lib: {} })
        core.start_driver

        assert_requested(:post, 'http://127.0.0.1:4723/wd/hub/session', times: 1)
        assert_requested(:post, "#{Mock::SESSION}/timeouts", body: { implicit: 0 }.to_json, times: 1)

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
          someCapability2: 'someCapability2'
        }
        base_caps = Appium::Core::Base::Capabilities.create_capabilities(cap)

        expected = {
          proxy: nil,
          platformName: :ios,
          'appium:automationName' => 'XCUITest',
          'appium:app' => 'test/functional/app/UICatalog.app.zip',
          'appium:platformVersion' => '11.4',
          'appium:deviceName' => 'iPhone Simulator',
          'appium:useNewWDA' => true,
          'appium:some_capability1' => 'some_capability1',
          'appium:someCapability2' => 'someCapability2'
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
