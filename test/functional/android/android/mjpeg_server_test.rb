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
