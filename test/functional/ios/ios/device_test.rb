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
require 'functional/common_w3c_actions'

require 'base64'

# $ rake test:func:ios TEST=test/functional/ios/ios/device_test.rb
# rubocop:disable Style/ClassVars
class AppiumLibCoreTest
  module Ios
    class DeviceTest < AppiumLibCoreTest::Function::TestCase
      ACTIVITY_INDICATORS = 'Activity Indicators'
      TEXT_FIELD = 'Text Fields'

      private

      def alert_view_cell
        over_ios13?(@@driver) ? 'Alert Controller' : 'Alert Views'
      end

      public

      def setup
        @@core = ::Appium::Core.for Caps.ios
        @@driver ||= @@core.start_driver
      end

      def teardown
        save_reports(@@driver)
      end

      def test_window_size
        size = @@driver.window_size
        assert size.width
        assert size.height
      end

      def test_window_rect
        size = @@driver.window_rect
        assert size.width
        assert size.height
        assert size.x
        assert size.y
      end

      def test_shake
        # Does not raise an error
        @@driver.shake
      end

      def test_lock_unlock
        @@driver.lock
        # Unstable on CI
        @@core.wait { assert @@driver.device_locked? } unless ci?

        @@driver.unlock
        @@core.wait { assert !@@driver.device_locked? }
      end

      def test_background_reset
        @@driver.background_app 5
        e = @@core.wait { @@driver.find_element :accessibility_id, alert_view_cell }
        assert_equal alert_view_cell, e.name

        @@driver.background_app(-1)
        error = assert_raises ::Selenium::WebDriver::Error::WebDriverError do
          @@driver.find_element :accessibility_id, alert_view_cell
        end
        assert 'An element could not be located on the page using the given search parameters.', error.message

        @@driver.activate_app 'com.example.apple-samplecode.UICatalog'

        e = @@core.wait { @@driver.find_element :accessibility_id, alert_view_cell }
        assert_equal alert_view_cell, e.name
      end

      def test_device_time
        require 'date'
        assert Date.parse(@@driver.device_time).is_a?(Date)
      end

      def test_context_related
        w3c_scroll @@driver

        e = @@core.wait { @@driver.find_element :accessibility_id, 'Web View' }
        e.click

        webview_context = @@core.wait do
          context = @@driver.available_contexts.detect { |c| c.start_with?('WEBVIEW') }
          assert context
          context
        end

        @@driver.set_context webview_context
        @@core.wait { assert @@driver.current_context.start_with? 'WEBVIEW' }

        @@driver.set_context 'NATIVE_APP'
        assert_equal 'NATIVE_APP', @@driver.current_context

        @@driver.back # go to top
        @@core.wait { assert [1, 2].member? @@driver.available_contexts.size }
      end

      def test_app_string
        default_lang = over_ios13?(@@driver) ? 'Base' : 'en'
        assert_equal 'A Short Title Is Best', @@driver.app_strings(default_lang)['A Short Title Is Best']
      end

      def test_re_install
        skip_as_appium_version '1.13.0'

        assert @@driver.app_installed?('com.example.apple-samplecode.UICatalog')

        @@driver.remove_app 'com.example.apple-samplecode.UICatalog'
        assert !@@driver.app_installed?('com.example.apple-samplecode.UICatalog')

        @@driver.install_app Caps.ios[:caps][:app]
        assert @@driver.app_installed?('com.example.apple-samplecode.UICatalog')
      end

      def test_app_management
        skip_as_appium_version '1.10.0'

        assert @@driver.app_state('com.example.apple-samplecode.UICatalog') == :running_in_foreground

        assert @@driver.terminate_app('com.example.apple-samplecode.UICatalog')
        assert @@driver.app_state('com.example.apple-samplecode.UICatalog') == :not_running

        @@driver.execute_script('mobile: launchApp',
                                {
                                  bundleId: 'com.example.apple-samplecode.UICatalog',
                                  arguments: %w(arg1 arg2),
                                  environment: { IOS_TESTING: 'happy testing' }
                                })

        # add check the arguments
        # info = @driver.execute_script('mobile: activeAppInfo', {})
        # assert info['processArguments']['args'] == ['arg1', 'arg2']
        # assert info['processArguments']['env'] == { 'IOS_TESTING': 'happy testing' }
        # assert info['bundleId'] == 'com.example.apple-samplecode.UICatalog'

        @@driver.activate_app('com.example.apple-samplecode.UICatalog')
        assert @@driver.app_state('com.example.apple-samplecode.UICatalog') == :running_in_foreground
      end

      def test_pull_file
        # Only pulling files from application containers is supported for iOS Simulator.
        # Provide the remote path in format @<bundle_id>/<path_to_the_file_in_its_container>
        read_file = @@driver.pull_file 'Library/AddressBook/AddressBook.sqlitedb'
        assert read_file.start_with?('SQLite format')

        # for real device
        # data = @@driver.pull_file '@com.apple.Keynote:documents/higher_from_pull.png'
        # File.open('higher_from_pull.png', 'wb') { |f| f<< data }
      end

      def test_push_file
        skip
        # @driver.push_file path, filedata

        # for real device
        # data = File.read 'test/functional/data/test_normal.png'
        # @@driver.push_file '@com.apple.Keynote:documents/higher.png', data
      end

      def test_pull_folder
        data = @@driver.pull_folder 'Library/AddressBook'
        assert data.length > 1

        # for real device
        # data = @@driver.pull_folder '@com.apple.Keynote:documents/'
        # File.open('pulled_data.zip', 'wb') { |f| f<< data }
      end

      def test_settings
        assert_equal(false, @@driver.get_settings['nativeWebTap'])

        @@driver.update_settings({ 'nativeWebTap' => true })
        assert_equal(true, @@driver.get_settings['nativeWebTap'])

        @@driver.update_settings({ 'nativeWebTap' => false })
      end

      # @deprecated Appium::Core::TouchAction
      def test_touch_actions
        element = @@core.wait { @@driver.find_element :accessibility_id, ACTIVITY_INDICATORS }

        @@driver.execute_script('mobile: tap', x: 0, y: 0, element: element.id)

        @@driver.back
      end

      # @deprecated Appium::Core::TouchAction
      def test_swipe
        el = @@core.wait { @@driver.find_element :accessibility_id, ACTIVITY_INDICATORS }
        rect = el.rect

        touch_action = Appium::Core::TouchAction
                       .new(@@driver)
                       .swipe(start_x: 75, start_y: 500, end_x: 75, end_y: 300, duration: 500)

        assert_equal :press, touch_action.actions[0][:action]
        assert_equal({ x: 75, y: 500 }, touch_action.actions[0][:options])

        assert_equal :wait, touch_action.actions[1][:action]
        assert_equal({ ms: 500 }, touch_action.actions[1][:options])

        assert_equal :moveTo, touch_action.actions[2][:action]
        assert_equal({ x: 75, y: 300 }, touch_action.actions[2][:options])

        assert_equal :release, touch_action.actions[3][:action]

        touch_action.perform
        assert_equal [], touch_action.actions

        # If test target has long height, el should be equal
        assert rect.y >= el.rect.y
      end

      def test_touch_id
        skip_as_appium_version '1.10.0' # unstable under 1.10.0-

        assert_nil @@driver.toggle_touch_id_enrollment
        assert_nil @@driver.toggle_touch_id_enrollment(true)
        assert_nil @@driver.toggle_touch_id_enrollment(false)
      end

      def test_hidekeyboard
        w3c_scroll @@driver

        e = @@core.wait { @@driver.find_element :accessibility_id, TEXT_FIELD }
        e.click

        text = @@core.wait { @@driver.find_element :predicate, 'value == "Placeholder text"' }
        text.click

        assert @@core.wait { @@driver.find_element(:class, 'XCUIElementTypeKeyboard') }.displayed?

        @@core.wait do
          @@driver.hide_keyboard
          sleep 1 # wait animation
        end

        m = assert_raises ::Selenium::WebDriver::Error::WebDriverError do
          @@driver.find_element(:class, 'XCUIElementTypeKeyboard')
        end
        assert 'An element could not be located on the page using the given search parameters.', m.message

        @@driver.back
      end

      def test_within_context
        result = @@driver.within_context('NATIVE_APP') do
          @@core.wait { @@driver.find_element :accessibility_id, 'Buttons' }
        end

        assert_equal 'Buttons', result.name
      end

      def test_viewport_screenshot
        skip_as_appium_version '1.8.0'

        file = @@driver.save_viewport_screenshot AppiumLibCoreTest.path_of('ios_viewport_screenshot_test.png')

        assert File.exist?(file.path)

        File.delete file.path
        assert !File.exist?(file.path)
      end

      # Requires --relaxed-security server flag
      def test_start_performance_record_and_stop
        skip_as_appium_version '1.9.1'

        file_path = AppiumLibCoreTest.path_of('test_start_performance_record_and_stop.zip')
        File.delete file_path if File.exist? file_path

        @@driver.start_performance_record(timeout: 300_000, profile_name: 'Time Profiler')

        @@driver.find_element(:accessibility_id, 'Buttons').click
        sleep 2
        @@driver.back
        sleep 1

        # Get .zip file
        file = @@driver.get_performance_record(
          save_file_path: AppiumLibCoreTest.path_of('test_start_performance_record_and_stop'),
          profile_name: 'Time Profiler'
        )

        assert File.exist?(file.path)
      end

      def test_clipbord
        skip_as_appium_version '1.8.0'

        input = 'happy testing'

        @@driver.set_clipboard(content: input)

        # rubocop:disable  Layout/LineLength
        # iOS 13??
        # [Xcode] 2019-06-06 10:01:15.029776+0900 WebDriverAgentRunner-Runner[16270:2865385] [claims] Upload preparation for claim 248BF916-16D3-4341-AFC3-653E3A05CAFA completed with error: Error Domain=NSCocoaErrorDomain Code=256 "The file “2c4ee6c5be2695a3c528cde33df5228960042b03” couldn’t be opened." UserInfo={NSURL=file:///Users/kazu/Library/Developer/CoreSimulator/Devices/3D099C88-C162-494E-9260-D0ABCBB434B1/data/Library/Caches/com.apple.Pasteboard/eb77e5f8f043896faf63b5041f0fbd121db984dd/2c4ee6c5be2695a3c528cde33df5228960042b03, NSFilePath=/Users/kazu/Library/Developer/CoreSimulator/Devices/3D099C88-C162-494E-9260-D0ABCBB434B1/data/Library/Caches/com.apple.Pasteboard/eb77e5f8f043896faf63b5041f0fbd121db984dd/2c4ee6c5be2695a3c528cde33df5228960042b03, NSUnderlyingError=0x600003855dd0 {Error Domain=NSPOSIXErrorDomain Code=22 "Invalid argument"}}
        # rubocop:enable  Layout/LineLength
        assert_equal input, @@driver.get_clipboard # does not work
      end

      def test_battery_info
        skip_as_appium_version '1.8.0'

        result = @@driver.battery_info

        assert !result[:state].nil?
        assert !result[:level].nil?
      end
    end
  end
end
# rubocop:enable Style/ClassVars
