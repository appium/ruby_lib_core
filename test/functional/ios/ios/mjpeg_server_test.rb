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
        @@driver.update_settings({ mjpegServerScreenshotQuality: 10, mjpegServerFramerate: 1 })
        @@driver.update_settings({ mjpegServerScreenshotQuality: 0, mjpegServerFramerate: -100 })
        @@driver.update_settings({ mjpegServerScreenshotQuality: -10, mjpegServerFramerate: 60 })
        @@driver.update_settings({ mjpegServerScreenshotQuality: 100, mjpegServerFramerate: 60 })
      end
    end
  end
end
