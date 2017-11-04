require 'test_helper'

# $ rake test:func:ios TEST=test/functional/ios/ios/device_test.rb
class AppiumLibCoreTest
  module Ios
    class DeviceTest < Minitest::Test
      def setup
        @@core ||= ::Appium::Core.for(self, Caps::IOS_OPS)
        @@driver ||= @@core.start_driver
      end

      def test_window_size
        size = @@driver.window_size
        assert size.width
        assert size.height
      end

      def test_shake
        skip 'NotImplemented'  if @@core.automation_name == :xcuitest

        assert @@driver.shake
      end

      def test_close_and_launch_app
        @@driver.close_app
        assert_equal ['NATIVE_APP'],@@driver.available_contexts

        @@driver.launch_app
        e = @@core.wait { @@driver.find_element :accessibility_id, 'TextView' }
        assert_equal 'TextView', e.name
      end

      def test_lock_unlock
        skip 'NotImplemented'  if @@core.automation_name == :xcuitest

        @@driver.lock 5
        assert @@driver.device_locked?

        @@driver.unlock
        assert !@@driver.device_locked?
      end

      def test_background_reset
        @@driver.background_app 5
        e = @@core.wait { @@driver.find_element :accessibility_id, 'TextView' }
        assert_equal 'TextView', e.name

        @@driver.background_app -1
        assert_raises Selenium::WebDriver::Error::NoSuchElementError do
          @@driver.find_element :accessibility_id, 'TextView'
        end

        @@driver.reset

        e = @@core.wait { @@driver.find_element :accessibility_id, 'TextView' }
        assert_equal 'TextView', e.name
      end

      def test_device_time
        require 'date'
        assert DateTime.parse(@@driver.device_time).is_a?(DateTime)
      end

      def test_context_related
        e = @@core.wait { @@driver.find_element :accessibility_id, 'Web' }
        e.click

        contexts = @@driver.available_contexts
        assert_equal ['NATIVE_APP'], contexts

        assert_equal 'NATIVE_APP',@@driver.current_context

        @@driver.set_context contexts.last
        assert_match 'NATIVE_APP' ,@@driver.current_context

        @@driver.set_context 'NATIVE_APP'
        assert_equal 'NATIVE_APP',@@driver.current_context

        @@driver.back # go to top
      end

      def test_app_string
        assert_equal 'Use of UISearchBar',@@driver.app_strings['SearchBarExplain']
      end

      def test_re_install
        skip 'NotImplemented'  if @@core.automation_name == :xcuitest

        assert @@driver.app_installed?('io.appium.bundle')

        @@driver.remove_app 'io.appium.bundle'
        assert !@@driver.app_installed?('io.appium.bundle')

        @@driver.install_app Caps::IOS_OPS[:caps][:app]
        assert @@driver.app_installed?('io.appium.bundle')
      end

      def test_push_pull
        read_file = @@driver.pull_file 'Library/AddressBook/AddressBook.sqlitedb'
        assert read_file.start_with?('SQLite format')
      end

      def test_push_file
        skip
        # @driver.push_file path, filedata
      end

      def test_pull_folder
        data = @@driver.pull_folder 'Library/AddressBook'
        assert 1 < data.length
      end

      def test_settings
        assert_equal({ 'nativeWebTap' => false }, @@driver.get_settings)

        @@driver.update_settings('nativeWebTap': true)
        assert_equal({ 'nativeWebTap' => true }, @@driver.get_settings)
      end

      def test_touch_actions
        if @@core.automation_name == :xcuitest
          element = @@core.wait { @@driver.find_element :accessibility_id, 'TextView' }
          @@driver.execute_script 'mobile: tap', { x: 0, y: 0, element: element.ref }
        else
          Appium::Core::TouchAction.new(@@driver)
              .press(element: @@driver.find_element(:accessibility_id, 'TextView'))
              .perform
        end

        @@core.wait { @@driver.find_element :accessibility_id, 'Back' }
        @@driver.back
      end

      def test_swipe
        touch_action = Appium::Core::TouchAction.new(@@driver)
                           .swipe(start_x: 75, start_y: 500, offset_x: 75, offset_y: 20, duration: 500)
                           .perform
        assert_equal [], touch_action.actions

        touch_action = Appium::Core::TouchAction.new(@@driver)
                           .swipe(start_x: 75, start_y: 500, offset_x: 75, offset_y: 20, duration: 500)

        assert_equal :press, touch_action.actions[0][:action]
        assert_equal({ x: 75, y: 500 }, touch_action.actions[0][:options])

        assert_equal :wait, touch_action.actions[1][:action]
        assert_equal({ ms: 500 }, touch_action.actions[1][:options])

        assert_equal :moveTo, touch_action.actions[2][:action]
        assert_equal({ x: 75, y: 20 }, touch_action.actions[2][:options])

        assert_equal :release, touch_action.actions[3][:action]

        touch_action.perform
        assert_equal [], touch_action.actions
      end

      def test_touch_id
        assert_nil @@driver.toggle_touch_id_enrollment
        assert_nil @@driver.toggle_touch_id_enrollment(true)
        assert_nil @@driver.toggle_touch_id_enrollment(false)
      end

      def test_hidekeyboard
        e = @@core.wait { @@driver.find_element :accessibility_id, 'TextFields' }
        e.click

        text = @@core.wait { @@driver.find_element :name, '<enter text>' }
        text.click

        assert @@driver.find_element(:class, 'XCUIElementTypeKeyboard').displayed?

        @@core.wait {
          @@driver.hide_keyboard
          sleep 1 # wait animation
        }

        m = assert_raises Selenium::WebDriver::Error::NoSuchElementError do
          @@driver.find_element(:class, 'XCUIElementTypeKeyboard')
        end
        assert 'An element could not be located on the page using the given search parameters.', m.message

        @@driver.back
      end
    end
  end
end
