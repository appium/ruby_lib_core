require 'test_helper'

# $ rake test:func:android TEST=test/functional/android/webdriver/device_test.rb
class AppiumLibCoreTest
  module WebDriver
    class DeviceTest < Minitest::Test
      def setup
        @@core ||= ::Appium::Core.for(self, Caps::ANDROID_OPS)
        @@driver ||= @@core.start_driver

        @@driver.start_activity app_package: 'io.appium.android.apis',
                                app_activity: '.ApiDemos'
      end

      def test_capabilities
        assert @@driver.capabilities
      end

      def test_remote_status
        status = @@driver.remote_status

        assert !status['build']['version'].nil?
        assert !status['build']['revision'].nil?
      end

      # TODO: replace_value

      def test_set_immediate_value
        @@core.wait { @@driver.find_element :accessibility_id, 'App' }.click
        @@core.wait { @@driver.find_element :accessibility_id, 'Activity' }.click
        @@core.wait { @@driver.find_element :accessibility_id, 'Custom Title' }.click

        e = @@core.wait { @@driver.find_element :id, 'io.appium.android.apis:id/left_text_edit' }
        @@driver.set_immediate_value e, 'hello'

        text = @@core.wait { @@driver.find_element :id, 'io.appium.android.apis:id/left_text_edit' }
        assert_equal 'Left is besthello', text.name
      end

      def test_page_source
        assert @@driver.page_source
      end

      def test_location
        latitude = 100
        longitude = 100
        altitude = 75
        @@driver.set_location(latitude, longitude, altitude)

        loc = @@driver.location # check the location
        assert_equal 100, loc.latitude
        assert_equal 100, loc.longitude
        assert_equal 75, loc.altitude
      end

      def test_accept_alert
        @@core.wait { @@driver.find_element :accessibility_id, 'App' }.click
        @@core.wait { @@driver.find_element :accessibility_id, 'Alert Dialogs' }.click

        @@core.wait { @@driver.find_element :accessibility_id, 'OK Cancel dialog with a message' }.click

        # 'Could not proxy. Proxy error: Could not proxy command to remote server. Original error: 404 - ""'
        # assert @@driver.switch_to.alert.text.start_with?('Lorem ipsum dolor sit aie consectetur')
        # assert @@driver.switch_to.alert.dismiss
        assert_equal 'OK', @@driver.find_element(:id, 'android:id/button1').name
        assert @@driver.find_element(:id, 'android:id/button1').click
      end

      def test_dismiss_alert
        @@core.wait { @@driver.find_element :accessibility_id, 'App' }.click
        @@core.wait { @@driver.find_element :accessibility_id, 'Alert Dialogs' }.click

        @@core.wait { @@driver.find_element :accessibility_id, 'OK Cancel dialog with a message' }.click

        # 'Could not proxy. Proxy error: Could not proxy command to remote server. Original error: 404 - ""'
        # assert @@driver.switch_to.alert.text.start_with?('Lorem ipsum dolor sit aie consectetur')
        # assert @@driver.switch_to.alert.dismiss

        assert_equal 'CANCEL', @@driver.find_element(:id, 'android:id/button2').name
        assert @@driver.find_element(:id, 'android:id/button2').click
      end

      def test_implicit_wait
        # checking no method error
        assert(@@driver.manage.timeouts.implicit_wait = @@core.default_wait)
      end

      def test_rotate
        assert_equal :portrait, @@driver.orientation

        @@driver.rotation = :landscape
        assert_equal :landscape, @@driver.orientation

        @@driver.rotation = :portrait
        assert_equal :portrait, @@driver.orientation
      end
    end
  end
end
