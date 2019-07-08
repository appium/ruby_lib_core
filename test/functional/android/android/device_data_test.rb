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

# $ rake test:func:android TEST=test/functional/android/android/device_data_test.rb
# rubocop:disable Style/ClassVars
class AppiumLibCoreTest
  module Android
    class DeviceTest < AppiumLibCoreTest::Function::TestCase
      def setup
        @@core ||= ::Appium::Core.for(Caps.android)
        @driver = @@core.start_driver
      end

      def teardown
        save_reports(@driver)
        @@core.quit_driver
      end

      def test_push_and_pull_file
        file = 'aVZCT1J3MEtHZ29BQUF BTlNVaEVVZ0FBQXU0QUFB VTJDQUlBQUFCRnRhUl' \
          'JBQUFBQVhOU1IwSUFyczRjNlFBQQ0KQUJ4cFJFOVVBQUFBQWdBQUFBQUFBQUti'
        path = '/data/local/tmp/remote.txt'
        @@core.wait do
          @driver.push_file path, file
          read_file = @driver.pull_file path
          assert_equal file, read_file
        end
      end

      def test_pull_folder
        file = 'aVZCT1J3MEtHZ29BQUF BTlNVaEVVZ0FBQXU0QUFB VTJDQUlBQUFCRnRhUl' \
          'JBQUFBQVhOU1IwSUFyczRjNlFBQQ0KQUJ4cFJFOVVBQUFBQWdBQUFBQUFBQUti'
        path = '/data/local/tmp/remote.txt'
        @driver.push_file path, file

        data = @driver.pull_folder '/data/local/tmp'
        assert data.length > 100
      end

      # check
      def test_settings
        skip 'Espresso has not implemented settings api yet' if @@core.automation_name == :espresso

        assert_equal(false, @driver.get_settings['ignoreUnimportantViews'])

        @driver.update_settings('ignoreUnimportantViews' => true)
        assert_equal(true, @driver.get_settings['ignoreUnimportantViews'])

        @driver.update_settings('ignoreUnimportantViews' => false)
        assert_equal(false, @driver.get_settings['ignoreUnimportantViews'])
      end

      def test_performance_related
        skip

        expected = %w(batteryinfo cpuinfo memoryinfo networkinfo)
        assert_equal expected, @driver.get_performance_data_types.sort

        assert_equal [%w(user kernel), %w(0 0)],
                     @driver.get_performance_data(package_name: 'io.appium.android.apis',
                                                  data_type: 'cpuinfo',
                                                  data_read_timeout: 10)
      end

      def test_take_element_screenshot
        e = @@core.wait { @driver.find_element :accessibility_id, 'App' }
        @driver.take_element_screenshot(e, 'take_element_screenshot.png')

        assert File.exist? 'take_element_screenshot.png'

        File.delete 'take_element_screenshot.png'
      end

      def test_viewport_screenshot
        skip 'Espresso does not support save_viewport_screenshot' if @@core.automation_name == :espresso
        skip_as_appium_version '1.8.0'

        file = @driver.save_viewport_screenshot 'android_viewport_screenshot_test.png'

        assert File.exist?(file.path)

        File.delete file.path
        assert !File.exist?(file.path)
      end

      def test_clipbord
        input = 'happy testing'

        @driver.set_clipboard(content: input, label: 'Note')

        assert_equal input, @driver.get_clipboard
      end

      def test_battery_info
        skip 'Espresso does not support battery_info' if @@core.automation_name == :espresso

        result = @driver.battery_info

        assert !result[:state].nil?
        assert !result[:level].nil?
      end

      def test_file_management
        test_file = 'test/functional/data/test_element_image.png'
        sdcard_path = '/sdcard/Pictures'
        sdcard_file_path = "#{sdcard_path}/test_element_image.png"

        file = File.read test_file
        @driver.push_file sdcard_file_path, file

        read_file = @driver.pull_file sdcard_file_path
        File.open('test.png', 'wb') { |f| f << read_file }

        assert_equal File.size(test_file), File.size('test.png')

        folder = @driver.pull_folder sdcard_path
        File.open('pic_folder.zip', 'wb') { |f| f << folder }

        assert File.exist?('pic_folder.zip')

        File.delete 'test.png'
        File.delete 'pic_folder.zip'
      end
    end
  end
end
# rubocop:enable Style/ClassVars
