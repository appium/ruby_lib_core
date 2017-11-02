require 'test_helper'
require 'webmock/minitest'

# $ rake android TEST=test/android/android/device_test.rb
class AppiumLibCoreTest
  module Android
    class WebDriverTest < Minitest::Test
      HEADER = { 'Content-Type' => 'application/json; charset=utf-8', 'Cache-Control' => 'no-cache' }.freeze
      SESSION = 'http://127.0.0.1:4723/wd/hub/session/1234567890'.freeze

      def setup
        @core ||= ::Appium::Core.for(self, Caps::ANDROID_OPS)
        @driver ||= mock_create_session
      end

      def test_remote_status
        stub_request(:get, 'http://127.0.0.1:4723/wd/hub/status')
          .to_return(headers: HEADER, status: 200, body: { value: 'xxxx' }.to_json)

        @driver.remote_status

        assert_requested(:get, 'http://127.0.0.1:4723/wd/hub/status', times: 1)
      end

      def test_page_source
        stub_request(:post, "#{SESSION}/execute/sync")
          .to_return(headers: HEADER, status: 200, body: { value: 'xxxx' }.to_json)

        @driver.page_source

        assert_requested(:post, "#{SESSION}/execute/sync", times: 1)
      end

      def test_accept_alert
        stub_request(:get, "#{SESSION}/alert/text")
          .to_return(headers: HEADER, status: 200, body: { value: 'xxxx' }.to_json)
        stub_request(:post, "#{SESSION}/alert/accept")
          .to_return(headers: HEADER, status: 200, body: { value: 'xxxx' }.to_json)


        @driver.switch_to.alert.accept

        assert_requested(:post, "#{SESSION}/alert/accept", times: 1)
        assert_requested(:get, "#{SESSION}/alert/text", times: 1)
      end

      def test_dismiss_alert
        stub_request(:get, "#{SESSION}/alert/text")
          .to_return(headers: HEADER, status: 200, body: { value: 'xxxx' }.to_json)
        stub_request(:post, "#{SESSION}/alert/dismiss")
          .to_return(headers: HEADER, status: 200, body: { value: 'xxxx' }.to_json)

        @driver.switch_to.alert.dismiss

        assert_requested(:post, "#{SESSION}/alert/dismiss", times: 1)
        assert_requested(:get, "#{SESSION}/alert/text", times: 1)
      end

      def test_implicit_wait
        stub_request(:post, "#{SESSION}/timeouts")
          .to_return(headers: HEADER, status: 200, body: { value: 'xxxx' }.to_json)

        @driver.manage.timeouts.implicit_wait = 30

        assert_requested(:post, "#{SESSION}/timeouts", times: 2)
      end

      private

      def mock_create_session
        response = {
          value: {
            sessionId: '1234567890',
            capabilities: {
              platform: 'LINUX',
              webStorageEnabled: false,
              takesScreenshot: true,
              javascriptEnabled: true,
              databaseEnabled: false,
              networkConnectionEnabled: true,
              locationContextEnabled: false,
              warnings: {},
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
              app: '/test/apps/ApiDemos-debug.apk',
              newCommandTimeout: 240,
              unicodeKeyboard: true,
              resetKeyboard: true,
              deviceUDID: 'emulator-5554',
              deviceScreenSize: '1080x1920',
              deviceModel: 'Android SDK built for x86_64',
              deviceManufacturer: 'unknown',
              appPackage: 'com.example.android.apis',
              appWaitPackage: 'com.example.android.apis',
              appActivity: 'com.example.android.apis.ApiDemos',
              appWaitActivity: 'com.example.android.apis.ApiDemos'
            }
          }
        }.to_json

        stub_request(:post, 'http://127.0.0.1:4723/wd/hub/session')
          .to_return(headers: HEADER, status: 200, body: response)

        stub_request(:post, 'http://127.0.0.1:4723/wd/hub/session/1234567890/timeouts')
          .with(body: { implicit: 30_000 }.to_json)
          .to_return(headers: HEADER, status: 200, body: { value: nil }.to_json)

        driver = @core.start_driver

        assert_requested(:post, 'http://127.0.0.1:4723/wd/hub/session', times: 1)
        assert_requested(:post, 'http://127.0.0.1:4723/wd/hub/session/1234567890/timeouts', times: 1)

        assert_equal '1234567890', driver.session_id

        driver
      end
    end
  end
end
