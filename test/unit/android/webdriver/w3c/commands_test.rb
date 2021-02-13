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

# $ rake test:unit TEST=test/unit/android/webdriver/w3c/commands_test.rb
class AppiumLibCoreTest
  module Android
    module WebDriver
      module W3C
        class CommandsTest < Minitest::Test
          include AppiumLibCoreTest::Mock

          def setup
            @core ||= ::Appium::Core.for(Caps.android)
            @driver ||= android_mock_create_session_w3c
          end

          def test_no_session_id
            response = {
              value: {
                capabilities: {
                  platformName: :android,
                  automationName: 'uiautomator2',
                  app: 'test/functional/app/api.apk.zip',
                  platformVersion: '7.1.1',
                  deviceName: 'Android Emulator',
                  appPackage: 'io.appium.android.apis',
                  appActivity: 'io.appium.android.apis.ApiDemos',
                  someCapability: 'some_capability',
                  unicodeKeyboard: true,
                  resetKeyboard: true
                }
              }
            }.to_json

            stub_request(:post, 'http://127.0.0.1:4723/wd/hub/session')
              .to_return(headers: HEADER, status: 200, body: response)

            error = assert_raises ::Selenium::WebDriver::Error::WebDriverError do
              @core.start_driver
            end

            assert_equal 'no sessionId in returned payload', error.message
          end

          def test_remote_status
            stub_request(:get, 'http://127.0.0.1:4723/wd/hub/status')
              .to_return(headers: HEADER, status: 200, body: { value: 'xxxx' }.to_json)

            @driver.remote_status

            assert_requested(:get, 'http://127.0.0.1:4723/wd/hub/status', times: 1)
          end

          def test_page_source
            stub_request(:get, "#{SESSION}/source")
              .to_return(headers: HEADER, status: 200, body: { value: 'xxxx' }.to_json)

            @driver.page_source

            assert_requested(:get, "#{SESSION}/source", times: 1)
          end

          def test_get_location
            stub_request(:get, "#{SESSION}/location")
              .with(body: '')
              .to_return(headers: HEADER, status: 200, body: { value: { latitude: 1, longitude: 1, altitude: 1 } }.to_json)

            l = @driver.location

            assert_requested(:get, "#{SESSION}/location", times: 1)
            assert_equal [1, 1, 1], [l.latitude, l.longitude, l.altitude]
          end

          def test_set_location
            stub_request(:post, "#{SESSION}/location")
              .with(body: { location: { latitude: 1.0, longitude: 1.0, altitude: 1.0 } }.to_json)
              .to_return(headers: HEADER, status: 200, body: { value: nil }.to_json)

            @driver.location = ::Selenium::WebDriver::Location.new(1.0, 1.0, 1.0)
            @driver.set_location 1, 1, 1

            assert_requested(:post, "#{SESSION}/location", times: 2)
          end

          def test_rotate
            stub_request(:post, "#{SESSION}/orientation")
              .to_return(headers: HEADER, status: 200, body: { value: 'xxxx' }.to_json)

            @driver.rotation = :landscape

            assert_requested(:post, "#{SESSION}/orientation", times: 1)
          end

          def test_active_element
            stub_request(:get, "#{SESSION}/element/active")
              .to_return(headers: HEADER, status: 200, body: { value: 'xxxx' }.to_json)

            @driver.switch_to.active_element

            assert_requested(:get, "#{SESSION}/element/active", times: 1)
          end

          def test_session_capabilities
            stub_request(:get, SESSION.to_s)
              .to_return(headers: HEADER, status: 200, body: { value: { sample_key: 'xxx' } }.to_json)

            capability = @driver.session_capabilities
            assert capability.is_a? Selenium::WebDriver::Remote::W3C::Capabilities
            assert capability['sample_key'] == 'xxx'

            assert_requested(:get, SESSION.to_s, times: 1)
          end

          def test_finger_print
            stub_request(:post, "#{SESSION}/appium/device/finger_print")
              .with(body: { fingerprintId: 1 }.to_json)
              .to_return(headers: HEADER, status: 200, body: { value: { finger: 'name' } }.to_json)

            error = assert_raises ArgumentError do
              @driver.finger_print 0
            end
            assert_equal 'finger_id should be integer between 1 to 10. Not 0', error.message

            @driver.finger_print 1

            assert_requested(:post, "#{SESSION}/appium/device/finger_print", times: 1)
          end

          def test_remote
            stub_request(:get, "#{NOSESSION}/status")
              .to_return(headers: HEADER, status: 200, body: {
                value: {
                  build: {
                    version: '1.21.0',
                    'git-sh' => '5735c828f1ce00e99243368bd5a60acc70809dcd'
                  }
                }
              }.to_json)

            version = @driver.remote_status['build']['version']

            assert_requested(:get, "#{NOSESSION}/status", times: 1)
            assert version == '1.21.0'
          end
        end # class CommandsTest
      end # module W3C
    end # module WebDriver
  end # module Android
end # class AppiumLibCoreTest
