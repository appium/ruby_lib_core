require 'test_helper'

# $ rake test:func:android TEST=test/functional/android/webdriver/device_test.rb
# rubocop:disable Style/ClassVars
class AppiumLibCoreTest
  module WebDriver
    class DeviceTest < AppiumLibCoreTest::Function::TestCase
      def setup
        @@core ||= ::Appium::Core.for(self, Caps::ANDROID_OPS)
        @@driver ||= @@core.start_driver

        @@driver.start_activity app_package: 'io.appium.android.apis',
                                app_activity: 'io.appium.android.apis.ApiDemos'

        require 'pry'
        binding.pry
      end

      def teardown
        save_reports(@@driver)
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
        s_source = @@driver.page_source

        assert s_source.include?('o.appium.android.apis')
      end

      # def test_location
      #   latitude = 100
      #   longitude = 100
      #   altitude = 75
      #   @@driver.set_location(latitude, longitude, altitude)
      #
      #   loc = @@driver.location # check the location
      #   assert_equal 100, loc.latitude
      #   assert_equal 100, loc.longitude
      #   assert_equal 75, loc.altitude
      # end

      def test_accept_alert
        @@core.wait { @@driver.find_element :accessibility_id, 'App' }.click
        @@core.wait { @@driver.find_element :accessibility_id, 'Alert Dialogs' }.click

        @@core.wait { @@driver.find_element :accessibility_id, 'OK Cancel dialog with a message' }.click

        # 'Could not proxy. Proxy error: Could not proxy command to remote server. Original error: 404 - ""'
        # assert @@driver.switch_to.alert.text.start_with?('Lorem ipsum dolor sit aie consectetur')
        # assert @@driver.switch_to.alert.dismiss
        @@core.wait { assert_equal 'OK', @@driver.find_element(:id, 'android:id/button1').name.upcase }
        assert @@driver.find_element(:id, 'android:id/button1').click
      end

      def test_dismiss_alert
        @@core.wait { @@driver.find_element :accessibility_id, 'App' }.click
        @@core.wait { @@driver.find_element :accessibility_id, 'Alert Dialogs' }.click

        @@core.wait { @@driver.find_element :accessibility_id, 'OK Cancel dialog with a message' }.click

        # 'Could not proxy. Proxy error: Could not proxy command to remote server. Original error: 404 - ""'
        # assert @@driver.switch_to.alert.text.start_with?('Lorem ipsum dolor sit aie consectetur')
        # assert @@driver.switch_to.alert.dismiss

        # Because the results depends on OS version.
        @@core.wait { assert_equal 'CANCEL', @@driver.find_element(:id, 'android:id/button2').name.upcase }
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

      def test_logs
        # :logcat, :bugreport, :server in 1.7.2
        assert_equal %i(logcat bugreport server), @@driver.logs.available_types
        assert @@driver.logs.get(:logcat)
      end

      def test_network_connection
        assert @@driver.get_network_connection
        assert @@driver.network_connection_type
        assert @@driver.set_network_connection(6)
        # TODO: depends on selenium-webdriver. Test failed with webdriver 3.11.0 with a number.
        assert @@driver.network_connection_type = :all
      end

      def test_session_capability
        assert @@driver.session_capabilities['deviceUDID'] == 'emulator-5554'
      end

      def test_find_image
        e = @@driver.find_element_by_image './test/functional/data/test_element_image.png'
        assert_equal [39, 1014], [e.location.x, e.location.y]
        assert_equal [326, 62], [e.size.width, e.size.height]
        assert_equal([39, 1014, 326, 62], [e.rect.x, e.rect.y, e.rect.width, e.rect.height])
      end

      def test_find_images
        es = @@driver.find_elements_by_image(
          %w(./test/functional/data/test_element_image.png ./test/functional/data/test_has_blue.png)
        )

        e = es[0]
        assert_equal [39, 1014], [e.location.x, e.location.y]
        assert_equal [326, 62], [e.size.width, e.size.height]
        assert_equal([39, 1014, 326, 62], [e.rect.x, e.rect.y, e.rect.width, e.rect.height])

        assert_equal 2, es.size
      end
    end
  end
end
