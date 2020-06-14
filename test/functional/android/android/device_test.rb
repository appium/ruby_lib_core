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

# $ rake test:func:android TEST=test/functional/android/android/device_test.rb
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

      def test_window_size
        size = @driver.window_size
        assert size.width
        assert size.height
      end

      def test_window_rect
        size = @driver.window_rect
        assert size.width
        assert size.height
        assert size.x
        assert size.y
      end

      def test_shake
        skip
        assert @driver.shake
      end

      def test_close_and_launch_app
        if @@core.automation_name == :espresso
          assert_raises ::Selenium::WebDriver::Error::UnsupportedOperationError do
            @driver.close_app
          end
        else
          @driver.close_app
          assert(@@core.wait { @driver.app_state('io.appium.android.apis') != :running_in_foreground })
        end

        if @@core.automation_name == :espresso
          assert_raises ::Selenium::WebDriver::Error::UnsupportedOperationError do
            @driver.launch_app
          end
        else
          @driver.launch_app
          e = @@core.wait { @driver.find_element :accessibility_id, 'App' }
          assert_equal 'App', e.text
        end
      end

      def test_lock_unlock
        @driver.lock
        assert @driver.device_locked?

        @driver.unlock
        @@core.wait { assert !@driver.device_locked? }
      end

      def test_background_reset
        @driver.background_app 3

        e = @@core.wait { @driver.find_element :accessibility_id, 'App' }
        assert_equal 'App', e.text

        @driver.background_app(-1)
        sleep 1 # to wait the app has gone
        error = assert_raises ::Selenium::WebDriver::Error::WebDriverError do
          @driver.find_element :accessibility_id, 'App'
        end
        assert 'An element could not be located on the page using the given search parameters.', error.message

        @driver.reset

        e = @@core.wait(timeout: 60) { @driver.find_element :accessibility_id, 'App' }
        assert_equal 'App', e.text
      end

      def test_device_time
        require 'date'
        assert Date.parse(@driver.device_time).is_a?(Date)
      end

      def test_device_time_format
        require 'date'
        assert Date.parse(@driver.device_time('YYYY-MM-DD')).is_a?(Date)
      end

      def test_app_string
        assert @driver.app_strings.key? 'activity_save_restore'
      end

      def test_re_install
        assert @driver.app_installed?('io.appium.android.apis')

        @driver.remove_app 'io.appium.android.apis'
        assert !@driver.app_installed?('io.appium.android.apis')

        @driver.install_app "#{Dir.pwd}/#{Caps.android[:desired_capabilities][:app]}"
        assert @driver.app_installed?('io.appium.android.apis')

        assert !@driver.app_installed?('fake_app')
      end

      def test_app_management
        assert @driver.app_state('io.appium.android.apis') == :running_in_foreground

        assert @driver.terminate_app('io.appium.android.apis')
        @@core.wait { assert @driver.app_state('io.appium.android.apis') == :not_running }

        assert @driver.activate_app('io.appium.android.apis').nil?
        @@core.wait { assert @driver.app_state('io.appium.android.apis') == :running_in_foreground }
      end

      def test_start_activity
        e = @@core.wait { @driver.current_activity }
        assert_equal '.ApiDemos', e

        @driver.start_activity app_package: 'io.appium.android.apis',
                               app_activity: '.accessibility.AccessibilityNodeProviderActivity'
        e = @@core.wait { @driver.current_activity }
        assert true, e.include?('Node')

        # Espresso cannot launch my root launched activity: https://github.com/appium/appium-espresso-driver/pull/378#discussion_r250034209
        return if @@core.automation_name == :espresso

        @driver.start_activity app_package: 'com.android.settings', app_activity: '.Settings',
                               app_wait_package: 'com.android.settings', app_wait_activity: '.Settings'
        e = @@core.wait { @driver.current_activity }
        assert true, e.include?('Settings')

        @driver.start_activity app_package: 'io.appium.android.apis', app_activity: '.ApiDemos'
      end

      def test_current_package
        e = @@core.wait { @driver.current_package }
        assert_equal 'io.appium.android.apis', e
      end
    end
  end
end
# rubocop:enable Style/ClassVars
