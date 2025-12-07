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
        @driver&.quit
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

      def test_lock_unlock
        @driver.lock 0
        # Unstable on CI
        @@core.wait { assert @driver.device_locked? } unless ci?

        @driver.unlock
        @driver.wait_until { |d| assert !d.device_locked? }
      end

      def test_background_reset
        @driver.background_app 3

        e = @driver.wait_until { |d| d.find_element :accessibility_id, 'App' }
        assert_equal 'App', e.text

        @driver.background_app(-1)
        sleep 1 # to wait the app has gone
        assert @driver.app_state('io.appium.android.apis') != :running_in_foreground

        # Instrumentation process will crash in Espresso
        if @@core.automation_name == :espresso
          @driver.activate_app('io.appium.android.apis')
          @driver.wait_until { |d| assert d.app_state('io.appium.android.apis') == :running_in_foreground }
        else
          error = assert_raises ::Selenium::WebDriver::Error::WebDriverError do
            @driver.find_element :accessibility_id, 'App'
          end
          assert 'An element could not be located on the page using the given search parameters.', error.message

          @driver.activate_app('io.appium.android.apis')
        end

        e = @driver.wait(timeout: 60) { |d| d.find_element :accessibility_id, 'App' }
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

        webview_context = @@core.wait do
          @driver.execute_script 'mobile: getContexts', { waitForWebviewMs: 5000 }

          context = @driver.available_contexts.detect { |c| c.start_with?('WEBVIEW') }
          assert context
          context
        end

        @driver.set_context webview_context
        @driver.wait { |d| assert d.current_context.start_with? 'WEBVIEW' }

        webview_page = @driver.page_source

        @driver.set_context 'NATIVE_APP'
        @driver.wait { |d| assert_equal 'NATIVE_APP', d.current_context }
        assert native_page != webview_page
      end

      def test_app_string
        assert @driver.app_strings.key? 'activity_save_restore'
      end

      def test_re_install
        skip 'Instrumentation process will stop by remove_app in Espresso' if @@core.automation_name == :espresso

        assert @driver.app_installed?('io.appium.android.apis')

        @driver.remove_app 'io.appium.android.apis'
        assert !@driver.app_installed?('io.appium.android.apis')

        @driver.install_app Caps.test_app_android
        assert @driver.app_installed?('io.appium.android.apis')

        assert !@driver.app_installed?('fake_app')
      end

      def test_app_management
        assert @driver.app_state('io.appium.android.apis') == :running_in_foreground

        # Instrumentation process will crash in Espresso
        unless @@core.automation_name == :espresso
          assert @driver.terminate_app('io.appium.android.apis')
          @driver.wait_until { |d| assert d.app_state('io.appium.android.apis') == :not_running }
        end

        assert @driver.activate_app('io.appium.android.apis').nil?
        @driver.wait_until { assert @driver.app_state('io.appium.android.apis') == :running_in_foreground }
      end

      def test_current_package
        e = @driver.wait_until(&:current_package)
        assert_equal 'io.appium.android.apis', e
      end

      def test_hidekeyboard
        @driver.wait_until { |d| d.find_element :accessibility_id, 'App' }.click
        @driver.wait_until { |d| d.find_element :accessibility_id, 'Activity' }.click
        @driver.wait_until { |d| d.find_element :accessibility_id, 'Custom Title' }.click
        # make sure to show keyboard
        @driver.wait_until { |d| d.find_element :id, 'io.appium.android.apis:id/left_text_edit' }.click

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

        @driver.wait(&:hide_keyboard)
        sleep 1 # wait animation

        assert !@driver.is_keyboard_shown
      end

      def test_get_system_bars
        assert @driver.get_system_bars
      end

      def test_get_display_density
        assert @driver.get_display_density.positive?
      end

      def test_press_keycode
        # http://developer.android.com/reference/android/view/KeyEvent.html
        result = @driver.press_keycode(84) # it does not raise error
        assert result || result.nil?
      end

      def test_long_press_keycode
        # http://developer.android.com/reference/android/view/KeyEvent.html
        result = @driver.long_press_keycode(84) # it does not raise error
        assert result || result.nil?
      end

      def test_open_notifications
        skip if @@core.automation_name == :espresso

        @driver.open_notifications
        # shouldn't see the elements behind shade

        # Sometimes, we should wait animation
        @@core.wait(timeout: 5) do
          error = assert_raises ::Selenium::WebDriver::Error::WebDriverError do
            @driver.find_element :accessibility_id, 'Appium Settings'
          end
          assert 'An element could not be located on the page using the given search parameters.', error.message
        end

        # return to app
        @driver.back
        # should be able to see elements from app
        @@core.wait_true { @driver.find_element :accessibility_id, 'Accessibility' }
      end

      def test_ime_available_engines
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
          rid  = resource_id(text, "new UiSelector().resourceId(#{text})")
          args = if rid.empty?
                   ["new UiSelector().textContains(#{text})", "new UiSelector().descriptionContains(#{text})"]
                 else
                   [rid]
                 end
          args.each_with_index do |arg, index|
            elem = @driver.find_element :uiautomator,
                                        'new UiScrollable(new UiSelector().scrollable(true).instance(0))' \
                                        ".scrollIntoView(#{arg}.instance(0));"
            return elem
          rescue StandardError => e
            raise e if index == args.size - 1
          end
        end
      end

      def resource_id(string, on_match)
        return '' unless string

        unquote = string.match(/"(.+)"/)
        string = unquote[1] if unquote

        resource_id = %r{^[a-zA-Z_][a-zA-Z0-9._]*:[^\/]+\/\S+$}
        string.match(resource_id) ? on_match : ''
      end
    end
  end
end
# rubocop:enable Style/ClassVars
