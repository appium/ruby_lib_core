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

# $ rake test:func:android TEST=test/functional/android/android/mobile_commands_test.rb
class AppiumLibCoreTest
  module Android
    class MobileCommandsTest < AppiumLibCoreTest::Function::TestCase
      def setup
        @core = ::Appium::Core.for(Caps.android)
      end

      def teardown
        save_reports(@driver)
      end

      # @since Appium 1.12.0
      def test_permissions
        @driver = @core.start_driver
        skip_as_appium_version '1.12.0'

        package = 'io.appium.android.apis'
        type = {
          denied: 'denied',
          granted: 'granted',
          requested: 'requested'
        }

        action = {
          grant: 'grant',
          revoke: 'revoke'
        }

        permissions = ['android.permission.READ_CONTACTS']

        granted_permissions = @driver.execute_script 'mobile: getPermissions',
                                                     { type: type[:granted], appPackage: package }
        assert granted_permissions.member?(permissions.first)

        assert @driver.execute_script('mobile: getPermissions',
                                      { type: type[:denied], appPackage: package }).empty?
        assert @driver.execute_script('mobile: getPermissions',
                                      { type: type[:requested], appPackage: package }).member?(permissions.first)

        @driver.execute_script 'mobile: changePermissions',
                               { action: action[:revoke], appPackage: package, permissions: permissions }

        granted_permissions = @driver.execute_script 'mobile: getPermissions',
                                                     { type: type[:granted], appPackage: package }
        assert !granted_permissions.member?(permissions.first)

        @driver.execute_script 'mobile: changePermissions',
                               { action: action[:grant], appPackage: package, permissions: permissions }

        granted_permissions = @driver.execute_script 'mobile: getPermissions',
                                                     { type: type[:granted], appPackage: package }
        assert granted_permissions.member?(permissions.first)
      end

      # @since Appium 1.10.0
      def test_toast
        skip unless @core.automation_name == :espresso
        skip_as_appium_version '1.10.0'

        caps = Caps.android 'io.appium.android.apis.view.SecureView'
        @core = ::Appium::Core.for(caps)
        @driver = @core.start_driver
        @driver.find_element(:id, 'io.appium.android.apis:id/secure_view_toast_button').click

        assert @driver.execute_script 'mobile: isToastVisible', { text: 'A toast', isRegexp: true }

        sleep 5 # wait for disappearing the toast
        assert !@driver.execute_script('mobile: isToastVisible', { text: 'A toast', isRegexp: true })
      end

      # @since Appium 1.11.0
      def test_drawer
        skip unless @core.automation_name == :espresso
        skip_as_appium_version '1.11.0'

        @driver = @core.start_driver

        el = @driver.find_element(:accessibility_id, 'Views')

        assert_mobile_command_error 'mobile: openDrawer', { element: el.ref, gravity: 1 },
                                    'Could not open drawer'
        assert_mobile_command_error 'mobile: closeDrawer', { element: el.ref, gravity: 1 },
                                    'Could not close drawer'
      end

      # @since Appium 1.11.0 (Newer than 1.10.0)
      def test_datepicker
        skip unless @core.automation_name == :espresso
        skip_as_appium_version'1.11.0'

        caps = Caps.android 'io.appium.android.apis.view.DateWidgets1'
        @core = ::Appium::Core.for(caps)
        @driver = @core.start_driver

        @driver.find_element(:accessibility_id, 'change the date').click

        date_picker = @driver.find_element(:id, 'android:id/datePicker')
        @driver.execute_script('mobile: setDate', { year: 2020, monthOfYear: 10, dayOfMonth: 25, element: date_picker.ref })
        assert_equal 'Sun, Oct 25', @driver.find_element(:id, 'android:id/date_picker_header_date').text
      end

      # @since Appium 1.11.0 (Newer than 1.10.0)
      def test_timepicker
        skip unless @core.automation_name == :espresso
        skip_as_appium_version '1.11.0'

        caps = Caps.android 'io.appium.android.apis.view.DateWidgets2'
        @core = ::Appium::Core.for(caps)
        @driver = @core.start_driver

        time_el = @driver.find_element(:class, 'android.widget.TimePicker')
        @driver.execute_script('mobile: setTime', { hours: 11, minutes: 0, element: time_el.ref })
        assert @driver.find_element(:id, 'io.appium.android.apis:id/dateDisplay').text == '11:00'

        time_el = @driver.find_element(:class, 'android.widget.TimePicker')
        @driver.execute_script('mobile: setTime', { hours: 15, minutes: 15, element: time_el.ref })
        assert @driver.find_element(:id, 'io.appium.android.apis:id/dateDisplay').text == '15:15'
      end

      # @since Appium 1.11.0 (Newer than 1.10.0)
      def test_navigate_to
        skip unless @core.automation_name == :espresso
        skip_as_appium_version'1.11.0'

        @driver = @core.start_driver
        el = @driver.find_element(:accessibility_id, 'Views')

        assert_mobile_command_error 'mobile: navigateTo', { element: el.ref, menuItemId: -100 },
                                    'must be a non-negative number'
        assert_mobile_command_error 'mobile: navigateTo', { element: el.ref, menuItemId: 'no element' },
                                    'must be a non-negative number'
        # A test demo apk has no the element
        assert_mobile_command_error 'mobile: navigateTo', { element: el.ref, menuItemId: 10 },
                                    'Could not navigate to menu item 10'
      end

      # @since Appium 1.11.0 (Newer than 1.10.0)
      # It can work with `ViewPager` https://developer.android.com/reference/android/support/v4/view/ViewPager
      def test_scroll_page_on_view_pager
        skip unless @core.automation_name == :espresso
        skip_as_appium_version '1.11.0'

        @driver = @core.start_driver
        el = @driver.find_element(:accessibility_id, 'Views')

        assert_mobile_command_error 'mobile: scrollToPage',  { element: el.ref, scrollTo: 'right' },
                                    'Could not perform scroll to on element'
        assert_mobile_command_error 'mobile: scrollToPage',  { element: el.ref, scrollTo: '' },
                                    'Invalid scrollTo parameters'
        assert_mobile_command_error 'mobile: scrollToPage',  { element: el.ref, scrollToPage: -100 },
                                    'be a non-negative integer'
        error = assert_raises ::Selenium::WebDriver::Error::InvalidArgumentError do
          @driver.execute_script 'mobile: scrollToPage', { element: el.ref }
        end
        assert error.message.include? "Must provide either 'scrollTo' or 'scrollToPage'"

        # A test demo apk has no the element
        assert_mobile_command_error 'mobile: scrollToPage', { element: el.ref, scrollToPage: 2, smoothScroll: true },
                                    'Could not perform scroll to on element'
      end

      # @since Appium 1.11.0 (Newer than 1.10.0)
      # https://github.com/appium/appium-espresso-driver/blob/0e03d2ca63dd0e77277aa3c493d239456bc2a899/lib/commands/general.js#L135-L174
      def test_backdoor
        skip unless @core.automation_name == :espresso
        skip_as_appium_version '1.11.0'

        caps = Caps.android 'io.appium.android.apis.view.TextSwitcher1'
        @core = ::Appium::Core.for(caps)
        @driver = @core.start_driver

        assert_mobile_command_error 'mobile: backdoor', { target: :activity, methods: [{ name: 'noMethod', args: [] }] },
                                    'No public method noMethod definded on class io.appium.android.apis.view.TextSwitcher1'

        e = @driver.find_elements :class, 'android.widget.TextView'
        assert_equal '0', e.last.text

        type = @driver.execute_script('mobile: backdoor',
                                      { target: :element, elementId: e.last.ref, methods: [{ name: 'getTypeface' }] })
        assert type['mStyle']
      end

      # @since Appium 1.12.0 (Espresso driver 1.8.0~)
      def test_webatom
        skip unless @core.automation_name == :espresso
        skip_as_appium_version '1.12.0'

        caps = Caps.android 'io.appium.android.apis.view.WebView1'
        @core = ::Appium::Core.for(caps)
        @driver = @core.start_driver

        el = @driver.find_element :id, 'wv1'

        @driver.execute_script 'mobile: webAtoms', {
          webviewElement: el.ref,
          forceJavascriptEnabled: true,
          methodChain: [
            { name: 'withElement', atom: { name: 'findElement', locator: { using: 'ID', value: 'i_am_a_textbox' } } },
            { name: 'perform', atom: { name: 'webKeys', args: 'Hello world' } },
            { name: 'withElement', atom: { name: 'findElement', locator: { using: 'ID', value: 'i am a link' } } },
            { name: 'perform', atom: 'webClick' }
          ]
        }

        # Can use `atom` defined in https://developer.android.com/reference/android/support/test/espresso/web/webdriver/DriverAtoms
        # Locator: https://developer.android.com/reference/androidx/test/espresso/web/webdriver/Locator
        @driver.execute_script 'mobile: webAtoms', {
          webviewElement: el.ref,
          forceJavascriptEnabled: true,
          methodChain: [{
            name: 'withElement',
            atom: { name: 'findElement', locator: { using: 'XPATH', value: '/html/body' } }
          }]
        }

        # Raises an error if the method cannot find any DriverAtoms or necessary arguments
        error = assert_raises ::Selenium::WebDriver::Error::WebDriverError do
          @driver.execute_script 'mobile: webAtoms', {
            webviewElement: el.ref,
            forceJavascriptEnabled: true,
            methodChain: [{
              name: 'withElement',
              atom: { name: 'findElement', locator: { using: 'ERROR', value: '/html/body' } }
            }]
          }
        end
        assert error.message.include? "Cannot execute method on 'androidx.test.espresso.web.webdriver.DriverAtoms'."
      end

      def test_device_info
        skip_as_appium_version '1.10.0'

        @driver = @core.start_driver
        assert(@driver.execute_script('mobile: deviceInfo', {}).size > 0)
      end

      private

      def assert_mobile_command_error(command, args, expected_message)
        error = assert_raises ::Selenium::WebDriver::Error::UnknownError do
          @driver.execute_script command, args
        end
        assert error.message.include? expected_message
      end
    end
  end
end
