require 'test_helper'

# $ rake test:func:ios TEST=test/functional/android/android/mobile_commands_test.rb
class AppiumLibCoreTest
  module Android
    class MobileCommandsTest < AppiumLibCoreTest::Function::TestCase
      def setup
        @core = ::Appium::Core.for(Caps.android)
      end

      def teardown
        save_reports(@driver)
      end

      # @since Appium 1.10.0
      def test_toast
        skip unless @core.automation_name == :espresso

        @driver = @core.start_driver

        @driver.find_element(:accessibility_id, 'Views').click
        @driver.find_element(:accessibility_id, 'Secure View').click
        @driver.find_element(:id, 'id/secure_view_toast_button').click

        assert @driver.execute_script 'mobile: isToastVisible', { text: 'A toast', isRegexp: true }

        sleep 5 # wait for disappearing the toast
        assert !@driver.execute_script('mobile: isToastVisible', { text: 'A toast', isRegexp: true })
      end

      # @since Appium 1.11.0 (Newer than 1.10.0)
      def test_drawer
        skip unless @core.automation_name == :espresso

        @driver = @core.start_driver

        el = @driver.find_element(:accessibility_id, 'Views')

        error = assert_raises ::Selenium::WebDriver::Error::UnknownError do
          @driver.execute_script('mobile: openDrawer', { element: el.ref, gravity: 1 })
        end
        assert error.message.include? ' Could not open drawer'

        error = assert_raises ::Selenium::WebDriver::Error::UnknownError do
          @driver.execute_script('mobile: closeDrawer', { element: el.ref, gravity: 1 })
        end
        assert error.message.include? ' Could not close drawer'
      end

      # @since Appium 1.11.0 (Newer than 1.10.0)
      def test_datepicker
        skip unless @core.automation_name == :espresso

        caps = Caps.android.dup
        caps[:desired_capabilities][:appActivity] = 'io.appium.android.apis.view.DateWidgets1'
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

        caps = Caps.android.dup
        caps[:desired_capabilities][:appActivity] = 'io.appium.android.apis.view.DateWidgets2'
        @core = ::Appium::Core.for(caps)
        @driver = @core.start_driver

        time_el = @driver.find_element(:class, 'android.widget.TimePicker')
        @driver.execute_script('mobile: setTime', { hours: 11, minutes: 00, element: time_el.ref })
        assert @driver.find_element(:id, 'io.appium.android.apis:id/dateDisplay').text == '11:00'

        time_el = @driver.find_element(:class, 'android.widget.TimePicker')
        @driver.execute_script('mobile: setTime', { hours: 15, minutes: 15, element: time_el.ref })
        assert @driver.find_element(:id, 'io.appium.android.apis:id/dateDisplay').text == '15:15'
      end

      # @since Appium 1.11.0 (Newer than 1.10.0)
      def test_navigate_to
        skip unless @core.automation_name == :espresso

        @driver = @core.start_driver

        el = @driver.find_element(:accessibility_id, 'Views')

        error = assert_raises ::Selenium::WebDriver::Error::UnknownError do
          @driver.execute_script 'mobile: navigateTo', { element: el.ref, menuItemId: -100 }
        end
        assert error.message.include? 'must be a non-negative number'

        error = assert_raises ::Selenium::WebDriver::Error::UnknownError do
          @driver.execute_script 'mobile: navigateTo', { element: el.ref, menuItemId: 'no element' }
        end
        assert error.message.include? 'must be a non-negative number'

        # A test demo apk has no the element
        error = assert_raises ::Selenium::WebDriver::Error::UnknownError do
          @driver.execute_script 'mobile: navigateTo', { element: el.ref, menuItemId: 10 }
        end
        assert error.message.include? 'Could not navigate to menu item 10'
      end

      # @since Appium 1.11.0 (Newer than 1.10.0)
      def test_scroll_page_on_view_pager
        skip unless @core.automation_name == :espresso

        @driver = @core.start_driver

        el = @driver.find_element(:accessibility_id, 'Views')

        error = assert_raises ::Selenium::WebDriver::Error::UnknownError do
          @driver.execute_script 'mobile: scrollToPage', { element: el.ref, scrollToPage: -100 }
        end
        assert error.message.include? 'be a non-negative integer'

        error = assert_raises ::Selenium::WebDriver::Error::UnknownError do
          @driver.execute_script 'mobile: scrollToPage', { element: el.ref, scrollTo: 'right' }
        end
        assert error.message.include? 'Could not perform scroll to on element'

        error = assert_raises ::Selenium::WebDriver::Error::UnknownError do
          @driver.execute_script 'mobile: scrollToPage', { element: el.ref, scrollTo: '' }
        end
        assert error.message.include? 'Invalid scrollTo parameters'

        error = assert_raises ::Selenium::WebDriver::Error::UnknownError do
          @driver.execute_script 'mobile: scrollToPage', { element: el.ref, scrollToPage: -100 }
        end
        assert error.message.include? 'be a non-negative integer'

        error = assert_raises ::Selenium::WebDriver::Error::InvalidArgumentError do
          @driver.execute_script 'mobile: scrollToPage', { element: el.ref  }
        end
        assert error.message.include? "Must provide either 'scrollTo' or 'scrollToPage'"

        # A test demo apk has no the element
        error = assert_raises ::Selenium::WebDriver::Error::UnknownError do
          @driver.execute_script 'mobile: scrollToPage', { element: el.ref, scrollToPage: 2 }
        end
        assert error.message.include? 'Could not perform scroll to on element'
      end
    end
  end
end
