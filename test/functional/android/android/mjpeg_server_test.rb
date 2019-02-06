require 'test_helper'

# $ rake test:func:ios TEST=test/functional/android/android/mjpeg_server_test.rb
# rubocop:disable Style/ClassVars
class AppiumLibCoreTest
  module Android
    class MjpegServerTest < AppiumLibCoreTest::Function::TestCase
      def setup
        @@core ||= ::Appium::Core.for(Caps.android)
        @driver = @@core.start_driver
      end

      def teardown
        save_reports(@driver)
        @@core.quit_driver
      end

      def test_start_recording_screen
        to_path = 'recorded_file_android.mp4'
        File.delete to_path if File.exist? to_path

        @driver.start_recording_screen time_limit: '2'
        @driver.find_element(:accessibility_id, 'App').click
        sleep 2 # second
        @driver.stop_and_save_recording_screen to_path
        assert File.exist? to_path
      end
    end
  end
end
# rubocop:enable Style/ClassVars
