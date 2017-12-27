require 'test_helper'

# $ rake test:func:android TEST=test/functional/android/android/device_test.rb
# rubocop:disable Style/ClassVars
class AppiumLibCoreTest
  module Android
    class DeviceTest < AppiumLibCoreTest::Function::TestCase
      def setup
        @@core ||= ::Appium::Core.for(self, Caps::ANDROID_OPS)
        @@driver ||= @@core.start_driver

        @@driver.start_activity app_package: 'io.appium.android.apis',
                                app_activity: '.ApiDemos'
      end

      def teardown
        save_reports(@@driver)
      end

      def test_window_size
        size = @@driver.window_size
        assert size.width
        assert size.height
      end

      def test_shake
        skip
        assert @@driver.shake
      end

      def test_close_and_launch_app
        @@driver.close_app
        assert @@driver.available_contexts.include?('NATIVE_APP')

        @@driver.launch_app
        e = @@core.wait { @@driver.find_element :accessibility_id, 'App' }
        assert_equal 'App', e.name
      end

      def test_lock_unlock
        @@driver.lock
        assert @@driver.device_locked?

        @@driver.unlock
        assert !@@driver.device_locked?
      end

      def test_background_reset
        @@core.wait { @@driver.background_app 5 }

        e = @@core.wait { @@driver.find_element :accessibility_id, 'App' }
        assert_equal 'App', e.name

        @@driver.background_app(-1)
        assert_raises Selenium::WebDriver::Error::NoSuchElementError do
          @@driver.find_element :accessibility_id, 'App'
        end

        @@driver.reset

        e = @@core.wait { @@driver.find_element :accessibility_id, 'App' }
        assert_equal 'App', e.name
      end

      def test_device_time
        require 'date'
        assert Date.parse(@@driver.device_time).is_a?(Date)
      end

      def test_context_related
        @@core.wait { scroll_to('Views') }.click
        @@core.wait { scroll_to('WebView') }.click

        @@core.wait { assert_equal 'NATIVE_APP', @@driver.current_context }

        contexts = @@driver.available_contexts
        webview_context = contexts.detect { |e| e.start_with?('WEBVIEW') }

        @@driver.set_context webview_context
        @@core.wait { assert @@driver.current_context.start_with? 'WEBVIEW' }

        @@driver.switch_to_default_context
        @@core.wait { assert_equal 'NATIVE_APP', @@driver.current_context }
      end

      def test_app_string
        assert @@driver.app_strings.key? 'activity_save_restore'
      end

      def test_re_install
        assert @@driver.app_installed?('io.appium.android.apis')

        @@driver.remove_app 'io.appium.android.apis'
        assert !@@driver.app_installed?('io.appium.android.apis')

        @@driver.install_app "#{Dir.pwd}/#{Caps::ANDROID_OPS[:caps][:app]}"
        assert @@driver.app_installed?('io.appium.android.apis')

        assert !@@driver.app_installed?('fake_app')
      end

      def test_start_activity
        e = @@core.wait { @@driver.current_activity }
        assert_equal '.ApiDemos', e

        @@driver.start_activity app_package: 'io.appium.android.apis',
                                app_activity: '.accessibility.AccessibilityNodeProviderActivity'
        e = @@core.wait { @@driver.current_activity }
        assert true, e.include?('Node')

        @@driver.start_activity app_package: 'com.android.settings', app_activity: '.Settings',
                                app_wait_package: 'com.android.settings', app_wait_activity: '.Settings'
        e = @@core.wait { @@driver.current_activity }
        assert true, e.include?('Settings')

        @@driver.start_activity app_package: 'io.appium.android.apis',
                                app_activity: '.ApiDemos'
      end

      def test_current_package
        e = @@core.wait { @@driver.current_package }
        assert_equal 'io.appium.android.apis', e
      end

      def test_push_and_pull_file
        file = 'A Fine Day'
        path = '/data/local/tmp/remote.txt'
        @@core.wait do
          @@driver.push_file path, file
          read_file = @@driver.pull_file path
          assert_equal file, read_file
        end
      end

      def test_pull_folder
        data = @@driver.pull_folder '/data/local/tmp'
        assert data.length > 100
      end

      def test_settings
        assert_equal(false, @@driver.get_settings['ignoreUnimportantViews'])

        @@driver.update_settings('ignoreUnimportantViews' => true)
        assert_equal(true, @@driver.get_settings['ignoreUnimportantViews'])

        @@driver.update_settings('ignoreUnimportantViews' => false)
      end

      def test_touch_actions
        Appium::Core::TouchAction.new(@@driver)
                                 .press(element: @@driver.find_element(:accessibility_id, 'App'))
                                 .release
                                 .perform

        @@core.wait { @@driver.find_element :accessibility_id, 'Action Bar' }
        @@driver.back
      end

      def test_swipe
        touch_action = Appium::Core::TouchAction.new(@@driver)
                                                .swipe(start_x: 75, start_y: 500, offset_x: 75, offset_y: 20, duration: 500)

        assert_equal :press, touch_action.actions[0][:action]
        assert_equal({ x: 75, y: 500 }, touch_action.actions[0][:options])

        assert_equal :wait, touch_action.actions[1][:action]
        assert_equal({ ms: 500 }, touch_action.actions[1][:options])

        assert_equal :moveTo, touch_action.actions[2][:action]
        assert_equal({ x: 150, y: 520 }, touch_action.actions[2][:options])

        assert_equal :release, touch_action.actions[3][:action]

        touch_action.perform
        assert_equal [], touch_action.actions
      end

      def test_hidekeyboard
        @@core.wait { @@driver.find_element :accessibility_id, 'App' }.click
        @@core.wait { @@driver.find_element :accessibility_id, 'Activity' }.click
        @@core.wait { @@driver.find_element :accessibility_id, 'Custom Title' }.click

        assert @@driver.is_keyboard_shown

        @@core.wait do
          @@driver.hide_keyboard
        end
        sleep 1 # wait animation

        assert !@@driver.is_keyboard_shown
      end

      def test_performance_related
        skip

        expected = %w(batteryinfo cpuinfo memoryinfo networkinfo)
        assert_equal expected, @@driver.get_performance_data_types.sort

        assert_equal [%w(user kernel), %w(0 0)],
                     @@driver.get_performance_data(package_name: 'io.appium.android.apis',
                                                   data_type: 'cpuinfo',
                                                   data_read_timeout: 10)
      end

      def test_get_system_bars
        assert @@driver.get_system_bars
      end

      def test_get_display_density
        assert(@@driver.get_display_density > 0)
      end

      def test_keyevent
        skip('Because only for Selendroid')
        # http://developer.android.com/reference/android/view/KeyEvent.html
        assert @@driver.keyevent(176)
      end

      def test_press_keycode
        # http://developer.android.com/reference/android/view/KeyEvent.html
        assert @@driver.press_keycode(176)
      end

      def test_long_press_keycode
        # http://developer.android.com/reference/android/view/KeyEvent.html
        assert @@driver.long_press_keycode(176)
      end

      def test_open_notifications
        # test & comments from https://github.com/appium/appium/blob/master/test/functional/android/apidemos/notifications-specs.js#L19
        # get to the notification page
        @@core.wait { scroll_to('App').click }
        @@core.wait { scroll_to('Notification').click }
        @@core.wait { scroll_to('Status Bar').click }
        # create a notification
        @@core.wait { @@driver.find_element :accessibility_id, ':-|' }.click
        @@driver.open_notifications
        # shouldn't see the elements behind shade

        # Sometimes, we should wait animation
        @@core.wait(timeout: 5) do
          assert_raises Selenium::WebDriver::Error::NoSuchElementError do
            @@driver.find_element :accessibility_id, ':-|'
          end
        end

        # should see the notification
        @@core.wait_true { text 'Mood ring' }
        # return to app
        @@driver.back
        # should be able to see elements from app
        @@core.wait_true { @@driver.find_element :accessibility_id, ':-|' }
      end

      def test_ime_available_engins
        @@core.wait { @@driver.find_element :accessibility_id, 'App' }.click
        @@core.wait { @@driver.find_element :accessibility_id, 'Activity' }.click
        @@core.wait { @@driver.find_element :accessibility_id, 'Custom Title' }.click

        imes = @@driver.ime_available_engines
        assert imes.length > 1

        available_ime = imes.first
        @@core.wait { @@driver.ime_activate(available_ime) }
        assert_equal available_ime, @@driver.ime_active_engine
        assert @@driver.ime_activated

        @@core.wait { @@driver.ime_deactivate }
        refute_equal available_ime, @@driver.ime_active_engine

        @@core.wait { @@driver.ime_activate(available_ime) }
        assert_equal available_ime, @@driver.ime_active_engine
      end

      def test_within_context
        result = @@driver.within_context('NATIVE_APP') do
          @@core.wait { @@driver.find_element :accessibility_id, 'App' }
        end

        assert_equal 'App', result.text
      end

      def test_take_element_screenshot
        e = @@core.wait { @@driver.find_element :accessibility_id, 'App' }
        @@driver.take_element_screenshot(e, 'take_element_screenshot.png')

        assert File.exist? 'take_element_screenshot.png'

        File.delete 'take_element_screenshot.png'
      end

      private

      def scroll_to(text)
        text = %("#{text}")
        rid  = resource_id(text, "new UiSelector().resourceId(#{text});")
        args = rid.empty? ? ["new UiSelector().textContains(#{text})", "new UiSelector().descriptionContains(#{text})"] : [rid]
        args.each_with_index do |arg, index|
          begin
            elem = @@driver.find_element :uiautomator,
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

        resource_id = %r{^[a-zA-Z_][a-zA-Z0-9\._]*:[^\/]+\/[\S]+$}
        string.match(resource_id) ? on_match : ''
      end

      def text(value)
        @@driver.find_element :uiautomator, "new UiSelector().className(\"android.widget.TextView\").text(\"#{value}\");"
      end
    end
  end
end
