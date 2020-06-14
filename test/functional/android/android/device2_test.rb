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
        skip if @@core.automation_name == :espresso

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

        @@core.wait do
          @driver.ime_activate(available_ime)
          assert_equal available_ime, @driver.ime_active_engine
        end
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
