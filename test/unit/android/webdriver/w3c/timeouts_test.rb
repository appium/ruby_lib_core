require 'test_helper'
require 'webmock/minitest'

# $ rake test:unit TEST=test/unit/android/webdriver/w3c/timeouts_test.rb
class AppiumLibCoreTest
  module Android
    module WebDriver
      module W3C
        class TimeoutsTest < Minitest::Test
          include AppiumLibCoreTest::Mock

          def setup
            @core ||= ::Appium::Core.for(Caps.android)
            @driver ||= android_mock_create_session_w3c
          end

          def test_implicit_wait
            stub_request(:post, "#{SESSION}/timeouts")
              .with(body: { implicit: 30_000 }.to_json)
              .to_return(headers: HEADER, status: 200, body: { value: 'xxxx' }.to_json)

            @driver.manage.timeouts.implicit_wait = 30

            assert_requested(:post, "#{SESSION}/timeouts", body: { implicit: 30_000 }.to_json, times: 1)
          end

          def test_get_timeouts
            stub_request(:get, "#{SESSION}/timeouts")
              .to_return(headers: HEADER, status: 200, body: { value: 'xxxx' }.to_json)

            @driver.get_timeouts

            assert_requested(:get, "#{SESSION}/timeouts", times: 1)
          end
        end # class TimeoutsTest
      end # module W3C
    end # module WebDriver
  end # module Android
end # class AppiumLibCoreTest
