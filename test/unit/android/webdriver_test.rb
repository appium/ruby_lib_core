require 'test_helper'
require 'webmock/minitest'

# $ rake test:unit TEST=test/unit/android/device_test.rb
class AppiumLibCoreTest
  module Android
    class WebDriverTest < Minitest::Test
      include AppiumLibCoreTest::Mock

      def setup
        @core ||= ::Appium::Core.for(self, Caps::ANDROID_OPS)
        @driver ||= android_mock_create_session
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

    end
  end
end
