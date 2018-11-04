require 'test_helper'
require 'base64'

# $ rake test:func:ios TEST=test/functional/ios/ios/device_test.rb
# rubocop:disable Style/ClassVars
class AppiumLibCoreTest
  module Ios
    class DeviceTest < AppiumLibCoreTest::Function::TestCase
      def setup
        @@core ||= ::Appium::Core.for(Caps.ios)
        @@driver ||= @@core.start_driver
      end

      def test_image_element
        @@driver.update_settings({ fixImageFindScreenshotDims: false,
                                   fixImageTemplateSize: true,
                                   autoUpdateImageElementPosition: true })

        e = @@driver.find_element_by_image './test/functional/data/test_button_image_ios.png'

        assert e.inspect
        assert e.hash
        assert e.ref =~ /\Aappium-image-element-[a-z0-9\-]+/
        assert e.location.x
        assert e.location.y
        assert e.size.width
        assert e.size.height
        assert e.rect.x
        assert e.rect.y
        assert e.rect.width
        assert e.rect.height
        assert e.displayed?
      end

      def test_image_elements
        @@driver.update_settings({ fixImageTemplateSize: true,
                                   autoUpdateImageElementPosition: true })

        e = @@driver.find_elements_by_image './test/functional/data/test_arrow_multiple_ios.png'

        assert e[0].inspect
        assert e[0].hash
        assert e[0].ref =~ /\Aappium-image-element-[a-z0-9\-]+/
        assert e[0].location
        assert e[0].size
        assert e[0].rect
        assert e[0].displayed?
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
        skip 'NotImplemented' if @@core.automation_name == :xcuitest

        assert @@driver.shake
      end

      def test_close_and_launch_app
        @@driver.close_app
        assert_equal ['NATIVE_APP'], @@driver.available_contexts

        @@driver.launch_app
        e = @@core.wait { @@driver.find_element :accessibility_id, 'TextView' }
        assert_equal 'TextView', e.name
      end

      def test_lock_unlock
        @@driver.lock
        @@core.wait { assert @@driver.device_locked? }

        @@driver.unlock
        @@core.wait { assert !@@driver.device_locked? }
      end

      def test_background_reset
        @@driver.background_app 5
        e = @@core.wait { @@driver.find_element :accessibility_id, 'TextView' }
        assert_equal 'TextView', e.name

        @@driver.background_app(-1)
        error = assert_raises ::Selenium::WebDriver::Error::WebDriverError do
          @@driver.find_element :accessibility_id, 'TextView'
        end
        assert 'An element could not be located on the page using the given search parameters.', error.message

        @@driver.reset

        e = @@core.wait { @@driver.find_element :accessibility_id, 'TextView' }
        assert_equal 'TextView', e.name
      end

      def test_device_time
        require 'date'
        assert Date.parse(@@driver.device_time).is_a?(Date)
      end

      def test_context_related
        e = @@core.wait { @@driver.find_element :accessibility_id, 'Web' }
        e.click

        contexts = @@driver.available_contexts
        assert_equal ['NATIVE_APP'], contexts

        assert_equal 'NATIVE_APP', @@driver.current_context

        @@driver.context = contexts.last
        assert_match 'NATIVE_APP', @@driver.current_context

        @@driver.switch_to_default_context
        assert_equal 'NATIVE_APP', @@driver.current_context

        @@driver.back # go to top
      end

      def test_app_string
        assert_equal 'Use of UISearchBar', @@driver.app_strings['SearchBarExplain']
      end

      def test_re_install
        skip 'NotImplemented' if @@core.automation_name == :xcuitest

        assert @@driver.app_installed?('com.example.apple-samplecode.UICatalog')

        @@driver.remove_app 'com.example.apple-samplecode.UICatalog'
        assert !@@driver.app_installed?('com.example.apple-samplecode.UICatalog')

        @@driver.install_app Caps.ios[:caps][:app]
        assert @@driver.app_installed?('com.example.apple-samplecode.UICatalog')
      end

      def test_app_management
        assert @@driver.app_state('com.example.apple-samplecode.UICatalog') == :running_in_foreground

        assert @@driver.terminate_app('com.example.apple-samplecode.UICatalog')
        assert @@driver.app_state('com.example.apple-samplecode.UICatalog') == :not_running

        assert @@driver.activate_app('com.example.apple-samplecode.UICatalog') == {}
        assert @@driver.app_state('com.example.apple-samplecode.UICatalog') == :running_in_foreground
      end

      def test_pull_file
        # Only pulling files from application containers is supported for iOS Simulator.
        # Provide the remote path in format @<bundle_id>/<path_to_the_file_in_its_container>
        read_file = @@driver.pull_file 'Library/AddressBook/AddressBook.sqlitedb'
        assert read_file.start_with?('SQLite format')
      end

      def test_push_file
        skip
        # @driver.push_file path, filedata
      end

      def test_pull_folder
        data = @@driver.pull_folder 'Library/AddressBook'
        assert data.length > 1
      end

      def test_settings
        assert_equal(false, @@driver.get_settings['nativeWebTap'])

        @@driver.update_settings('nativeWebTap' => true)
        assert_equal(true, @@driver.get_settings['nativeWebTap'])

        @@driver.update_settings('nativeWebTap' => false)
      end

      def test_touch_actions
        if @@core.automation_name == :xcuitest
          element = @@core.wait { @@driver.find_element :accessibility_id, 'TextView' }
          @@driver.execute_script('mobile: tap', x: 0, y: 0, element: element.ref)
        else
          Appium::Core::TouchAction.new(@@driver)
                                   .press(element: @@driver.find_element(:accessibility_id, 'TextView'))
                                   .perform
        end

        @@core.wait { @@driver.find_element :accessibility_id, 'Back' }
        @@driver.back
      end

      def test_swipe
        @@core.wait { @@driver.find_element :accessibility_id, 'Buttons' }.click

        el = @@core.wait { @@driver.find_element :accessibility_id, 'Gray' }
        rect = el.rect

        Appium::Core::TouchAction.new(@@driver)
                                 .swipe(start_x: 75, start_y: 500, end_x: 75, end_y: 500, duration: 500)
                                 .perform
        assert rect.x == el.rect.x
        assert rect.y == el.rect.y

        touch_action = Appium::Core::TouchAction.new(@@driver)
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

        @@driver.back
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
        file = @@driver.save_viewport_screenshot './ios_viewport_screenshot_test.png'

        assert File.exist?(file.path)

        File.delete file.path
        assert !File.exist?(file.path)
      end

      def test_start_performance_record_and_stop
        @@driver.start_performance_record(timeout: 300_000, profile_name: 'Activity Monitor')

        sleep 3

        file = @@driver.get_performance_record(save_file_path: './test_start_performance_record_and_stop',
                                               profile_name: 'Activity Monitor')

        assert File.exist?(file.path)

        File.delete file.path
        assert !File.exist?(file.path)
      end

      def test_clipbord
        input = 'happy testing'

        @@driver.set_clipboard(content: input)

        assert_equal input, @@driver.get_clipboard
      end

      def test_battery_info
        result = @@driver.battery_info

        assert !result[:state].nil?
        assert !result[:level].nil?
      end
    end
  end
end
# rubocop:enable Style/ClassVars
