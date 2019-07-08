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
        @driver.close_app
        assert @driver.available_contexts.include?('NATIVE_APP')

        @driver.launch_app
        e = @@core.wait { @driver.find_element :accessibility_id, 'App' }
        assert_equal 'App', e.text
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

      def test_context_related
        @@core.wait { scroll_to('Views') }.click
        @@core.wait { scroll_to('WebView') }.click

        @@core.wait { assert_equal 'NATIVE_APP', @driver.current_context }

        native_page = @driver.page_source

        contexts = @driver.available_contexts
        webview_context = contexts.detect { |e| e.start_with?('WEBVIEW') }

        @driver.set_context webview_context
        @@core.wait { assert @driver.current_context.start_with? 'WEBVIEW' }

        webview_page = @driver.page_source

        @driver.switch_to_default_context
        @@core.wait { assert_equal 'NATIVE_APP', @driver.current_context }
        assert native_page != webview_page
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

      def test_touch_actions
        Appium::Core::TouchAction.new(@driver)
                                 .press(element: @driver.find_element(:accessibility_id, 'App'))
                                 .release
                                 .perform

        @@core.wait { @driver.find_element :accessibility_id, 'Action Bar' }
        @driver.back
      end

      def test_swipe
        @@core.wait { @driver.find_element :accessibility_id, 'App' }.click

        el = @@core.wait { @driver.find_element :accessibility_id, 'Fragment' }
        rect = el.rect

        Appium::Core::TouchAction.new(@driver)
                                 .swipe(start_x: 75, start_y: 500, end_x: 75, end_y: 500, duration: 500)
                                 .perform
        @driver.back # The above command become "tap" action since it doesn't move.
        el = @@core.wait { @driver.find_element :accessibility_id, 'Fragment' }
        assert rect.x == el.rect.x
        assert rect.y == el.rect.y

        touch_action = Appium::Core::TouchAction.new(@driver)
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

        assert rect.x == el.rect.x
        assert rect.y > el.rect.y
      end

      def test_hidekeyboard
        @@core.wait { @driver.find_element :accessibility_id, 'App' }.click
        @@core.wait { @driver.find_element :accessibility_id, 'Activity' }.click
        @@core.wait { @driver.find_element :accessibility_id, 'Custom Title' }.click
        # make sure to show keyboard
        @@core.wait { @driver.find_element :id, 'io.appium.android.apis:id/left_text_edit' }.click

        latin_android = 'com.android.inputmethod.latin/.LatinIME'
        latin_google = 'com.google.android.inputmethod.latin/com.android.inputmethod.latin.LatinIME'
        imes = @driver.ime_available_engines
        ime_latin = if imes.member? latin_android # Android O-
                      latin_android
                    elsif imes.member? latin_google # Android O+
                      latin_google
                    else
                      imes.first
                    end
        @driver.ime_activate ime_latin

        assert @driver.keyboard_shown?

        @@core.wait { @driver.hide_keyboard }
        sleep 1 # wait animation

        assert !@driver.is_keyboard_shown
      end

      def test_get_system_bars
        assert @driver.get_system_bars
      end

      def test_get_display_density
        assert(@driver.get_display_density > 0)
      end

      def test_keyevent
        skip('Because only for Selendroid')
        # http://developer.android.com/reference/android/view/KeyEvent.html
        assert @driver.keyevent(176)
      end

      def test_press_keycode
        # http://developer.android.com/reference/android/view/KeyEvent.html
        result = @driver.press_keycode(176) # it does not raise error
        assert result || result.nil?
      end

      def test_long_press_keycode
        # http://developer.android.com/reference/android/view/KeyEvent.html
        result = @driver.long_press_keycode(176) # it does not raise error
        assert result || result.nil?
      end

      def test_open_notifications
        skip unless @@core.automation_name == :espresso

        # test & comments from https://github.com/appium/appium/blob/master/test/functional/android/apidemos/notifications-specs.js#L19
        # get to the notification page
        @@core.wait { scroll_to('App').click }
        @@core.wait { scroll_to('Notification').click }
        @@core.wait { scroll_to('Status Bar').click }
        # create a notification
        @@core.wait { @driver.find_element :accessibility_id, ':-|' }.click
        @driver.open_notifications
        # shouldn't see the elements behind shade

        # Sometimes, we should wait animation
        @@core.wait(timeout: 5) do
          error = assert_raises ::Selenium::WebDriver::Error::WebDriverError do
            @driver.find_element :accessibility_id, ':-|'
          end
          assert 'An element could not be located on the page using the given search parameters.', error.message
        end

        # should see the notification
        @@core.wait_true { text 'Mood ring' }
        # return to app
        @driver.back
        # should be able to see elements from app
        @@core.wait_true { @driver.find_element :accessibility_id, ':-|' }
      end

      def test_ime_available_engins
        @@core.wait { @driver.find_element :accessibility_id, 'App' }.click
        @@core.wait { @driver.find_element :accessibility_id, 'Activity' }.click
        @@core.wait { @driver.find_element :accessibility_id, 'Custom Title' }.click

        imes = @driver.ime_available_engines
        assert imes.length > 1

        available_ime = imes.first
        @@core.wait { @driver.ime_activate(available_ime) }
        assert_equal available_ime, @driver.ime_active_engine
        assert @driver.ime_activated

        @@core.wait { @driver.ime_deactivate }
        refute_equal available_ime, @driver.ime_active_engine

        @@core.wait { @driver.ime_activate(available_ime) }
        assert_equal available_ime, @driver.ime_active_engine
      end

      def test_within_context
        result = @driver.within_context('NATIVE_APP') do
          @@core.wait { @driver.find_element :accessibility_id, 'App' }
        end

        assert_equal 'App', result.text
      end

      private

      def scroll_to(text)
        if @@core.automation_name == :espresso
          @driver.find_element :accessibility_id, text
        else
          text = %("#{text}")
          rid  = resource_id(text, "new UiSelector().resourceId(#{text});")
          args = if rid.empty?
                   ["new UiSelector().textContains(#{text})", "new UiSelector().descriptionContains(#{text})"]
                 else
                   [rid]
                 end
          args.each_with_index do |arg, index|
            begin
              elem = @driver.find_element :uiautomator,
                                          'new UiScrollable(new UiSelector().scrollable(true).instance(0))' \
                                          ".scrollIntoView(#{arg}.instance(0));"
              return elem
            rescue StandardError => e
              raise e if index == args.size - 1
            end
          end
        end
      end

      def resource_id(string, on_match)
        return '' unless string

        unquote = string.match(/"(.+)"/)
        string = unquote[1] if unquote

        resource_id = %r{^[a-zA-Z_][a-zA-Z0-9\._]*:[^\/]+\/[\S]+$}
        string.match(resource_id) ? on_match : ''
      end

      def text(value)
        @driver.find_element :uiautomator, "new UiSelector().className(\"android.widget.TextView\").text(\"#{value}\");"
      end
    end
  end
end
# rubocop:enable Style/ClassVars
