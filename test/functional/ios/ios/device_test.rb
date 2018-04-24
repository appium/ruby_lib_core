require 'test_helper'

# $ rake test:func:ios TEST=test/functional/ios/ios/device_test.rb
# rubocop:disable Style/ClassVars
class AppiumLibCoreTest
  module Ios
    class DeviceTest < AppiumLibCoreTest::Function::TestCase
      def setup
        @@core ||= ::Appium::Core.for(self, Caps::IOS_OPS)
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
        @@driver.lock 5
        assert @@driver.device_locked?

        @@driver.unlock
        assert !@@driver.device_locked?
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

        @@driver.set_context contexts.last
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

        @@driver.install_app Caps::IOS_OPS[:caps][:app]
        assert @@driver.app_installed?('com.example.apple-samplecode.UICatalog')
      end

      def test_app_management
        assert @@driver.app_state('com.example.apple-samplecode.UICatalog') ==
               Appium::Core::Device::AppState::RUNNING_IN_FOREGROUND

        assert @@driver.terminate_app('com.example.apple-samplecode.UICatalog')
        assert @@driver.app_state('com.example.apple-samplecode.UICatalog') ==
               Appium::Core::Device::AppState::NOT_RUNNING

        assert @@driver.activate_app('com.example.apple-samplecode.UICatalog') == {}
        assert @@driver.app_state('com.example.apple-samplecode.UICatalog') ==
               Appium::Core::Device::AppState::RUNNING_IN_FOREGROUND
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

      def test_image_comparison_match_result
        image1 = File.read './test/functional/data/test_normal.png'
        image2 = File.read './test/functional/data/test_has_blue.png'

        match_result = @@driver.match_images_features first_image: image1, second_image: image2
        assert_equal %w(points1 rect1 points2 rect2 totalCount count), match_result.keys

        match_result_visual = @@driver.match_images_features first_image: image1, second_image: image2, visualize: true
        assert_equal %w(points1 rect1 points2 rect2 totalCount count visualization), match_result_visual.keys
        File.write 'match_result_visual.png', Base64.decode64(match_result_visual['visualization'])
        assert File.size? 'match_result_visual.png'

        File.delete 'match_result_visual.png'
      end

      def test_image_comparison_find_result
        image1 = File.read './test/functional/data/test_normal.png'
        image2 = File.read './test/functional/data/test_has_blue.png'

        find_result = @@driver.find_image_occurrence full_image: image1, partial_image: image2
        assert_equal({ 'rect' => { 'x' => 0, 'y' => 0, 'width' => 750, 'height' => 1334 } }, find_result)

        find_result_visual = @@driver.find_image_occurrence full_image: image1, partial_image: image2, visualize: true
        assert_equal %w(rect visualization), find_result_visual.keys
        File.write 'find_result_visual.png', Base64.decode64(find_result_visual['visualization'])
        assert File.size? 'find_result_visual.png'

        File.delete 'find_result_visual.png'
      end

      def test_image_comparison_get_images_result
        image1 = File.read './test/functional/data/test_normal.png'
        image2 = File.read './test/functional/data/test_has_blue.png'

        get_images_result = @@driver.get_images_similarity first_image: image1, second_image: image2
        assert_equal({ 'score' => 0.891606867313385 }, get_images_result)

        get_images_result_visual = @@driver.get_images_similarity first_image: image1, second_image: image2, visualize: true
        assert_equal %w(score visualization), get_images_result_visual.keys
        File.write 'get_images_result_visual.png', Base64.decode64(get_images_result_visual['visualization'])
        assert File.size? 'get_images_result_visual.png'

        File.delete 'get_images_result_visual.png'
      end
    end
  end
end
