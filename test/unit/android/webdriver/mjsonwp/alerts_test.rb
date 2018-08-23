require 'test_helper'
require 'webmock/minitest'

# $ rake test:unit TEST=test/unit/android/webdriver/mjsonwp/commands_test.rb
class AppiumLibCoreTest
  module Android
    module WebDriver
      module MJSONWP
        class AlertsTest < Minitest::Test
          include AppiumLibCoreTest::Mock

          def setup
            @core ||= ::Appium::Core.for(self, Caps.android)
            @driver ||= android_mock_create_session
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
        end # class AlertsTest
      end # module MJSONWP
    end # module WebDriver
  end # module Android
end # class AppiumLibCoreTest
