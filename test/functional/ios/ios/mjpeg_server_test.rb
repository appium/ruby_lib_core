require 'test_helper'

# $ rake test:func:ios TEST=test/functional/ios/ios/mjpeg_server_test.rb
# rubocop:disable Style/ClassVars
class AppiumLibCoreTest
  module Ios
    class MjpegServerTest < AppiumLibCoreTest::Function::TestCase
      def setup
        @@core ||= ::Appium::Core.for(Caps.ios)
        @@driver ||= @@core.start_driver
      end

      def teardown
        save_reports(@@driver)
      end

      # Can view via http://localhost:9100 by default
      def test_config
        skip 'It requires Appium 1.9.2' unless AppiumLibCoreTest.required_appium_version?(@@core, '1.9.2')

        @@driver.update_settings({ mjpegServerScreenshotQuality: 10, mjpegServerFramerate: 1 })
        @@driver.update_settings({ mjpegServerScreenshotQuality: 0, mjpegServerFramerate: -100 })
        @@driver.update_settings({ mjpegServerScreenshotQuality: -10, mjpegServerFramerate: 60 })
        @@driver.update_settings({ mjpegServerScreenshotQuality: 100, mjpegServerFramerate: 60 })
      end

      def test_start_recording_screen
        to_path = 'recorded_file_ios.avi'
        File.delete to_path if File.exist? to_path

        @@driver.start_recording_screen time_limit: '2', video_type: 'mjpeg'
        sleep 3 # second
        @@driver.stop_and_save_recording_screen to_path
        assert File.exist? to_path
      end
    end
  end
end
# rubocop:enable Style/ClassVars
