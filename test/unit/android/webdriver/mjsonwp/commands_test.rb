require 'test_helper'
require 'webmock/minitest'

# $ rake test:unit TEST=test/unit/android/device_test.rb
class AppiumLibCoreTest
  module Android
    module WebDriver
      module MJSONWP
        class CommandsTest < Minitest::Test
          include AppiumLibCoreTest::Mock

          def setup
            @core ||= ::Appium::Core.for(self, Caps::ANDROID_OPS)
            @driver ||= android_mock_create_session
          end

          def test_no_session_id
            response = {
              status: 0, # To make bridge.dialect == :oss
              value: {
                capabilities: {
                  desired: {
                    platformName: 'Android',
                    automationName: 'uiautomator2',
                    platformVersion: '7.1.1',
                    deviceName: 'Android Emulator',
                    app: '/test/apps/ApiDemos-debug.apk',
                    newCommandTimeout: 240,
                    unicodeKeyboard: true,
                    resetKeyboard: true
                  },
                  platformName: 'Android',
                  automationName: 'uiautomator2',
                  platformVersion: '7.1.1',
                  deviceName: 'emulator-5554',
                  app: '/test/apps/ApiDemos-debug.apk'
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

          def test_accept_alert
            stub_request(:get, "#{SESSION}/alert_text")
              .to_return(headers: HEADER, status: 200, body: { value: 'xxxx' }.to_json)
            stub_request(:post, "#{SESSION}/accept_alert")
              .to_return(headers: HEADER, status: 200, body: { value: 'xxxx' }.to_json)

            @driver.switch_to.alert.accept

            assert_requested(:post, "#{SESSION}/accept_alert", times: 1)
            assert_requested(:get, "#{SESSION}/alert_text", times: 1)
          end

          def test_dismiss_alert
            stub_request(:get, "#{SESSION}/alert_text")
              .to_return(headers: HEADER, status: 200, body: { value: 'xxxx' }.to_json)
            stub_request(:post, "#{SESSION}/dismiss_alert")
              .to_return(headers: HEADER, status: 200, body: { value: 'xxxx' }.to_json)

            @driver.switch_to.alert.dismiss

            assert_requested(:post, "#{SESSION}/dismiss_alert", times: 1)
            assert_requested(:get, "#{SESSION}/alert_text", times: 1)
          end

          def test_implicit_wait
            stub_request(:post, "#{SESSION}/timeouts/implicit_wait")
              .to_return(headers: HEADER, status: 200, body: { value: 'xxxx' }.to_json)

            @driver.manage.timeouts.implicit_wait = 30

            assert_requested(:post, "#{SESSION}/timeouts/implicit_wait", times: 2)
          end

          def test_active_element
            stub_request(:post, "#{SESSION}/element/active")
              .to_return(headers: HEADER, status: 200, body: { value: 'xxxx' }.to_json)

            @driver.switch_to.active_element

            assert_requested(:post, "#{SESSION}/element/active", times: 1)
          end

          def test_session_capabilities
            stub_request(:get, SESSION.to_s)
              .to_return(headers: HEADER, status: 200, body: { value: { sample_key: 'xxx' } }.to_json)

            capability = @driver.session_capabilities
            assert capability.is_a? Selenium::WebDriver::Remote::Capabilities
            assert capability['sample_key'] == 'xxx'

            assert_requested(:get, SESSION.to_s, times: 1)
          end
        end # class CommandsTest
      end # module MJSONWP
    end # module WebDriver
  end # module Android
end # class AppiumLibCoreTest
