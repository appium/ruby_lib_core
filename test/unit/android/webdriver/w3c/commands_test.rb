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
            @core ||= ::Appium::Core.for(self, Caps.android)
            @driver ||= android_mock_create_session_w3c
          end

          def test_no_session_id
            response = {
              value: {
                capabilities: {
                  platformName: :android,
                  automationName: 'uiautomator2',
                  app: 'test/functional/app/api.apk',
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

          def test_location
            stub_request(:get, "#{SESSION}/location")
              .to_return(headers: HEADER, status: 200, body: { value: 'xxxx' }.to_json)

            @driver.location

            assert_requested(:get, "#{SESSION}/location", times: 1)
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
        end # class CommandsTest
      end # module W3C
    end # module WebDriver
  end # module Android
end # class AppiumLibCoreTest
