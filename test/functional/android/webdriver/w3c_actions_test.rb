require 'test_helper'

# $ rake test:func:android TEST=test/functional/android/webdriver/w3c_actions_test.rb
# rubocop:disable Style/ClassVars
class AppiumLibCoreTest
  module WebDriver
    class W3CActionsTest < AppiumLibCoreTest::Function::TestCase
      def setup
        @@core ||= ::Appium::Core.for(Caps.android)
        @driver = @@core.start_driver
      end

      def teardown
        save_reports(@driver)
        @@core.quit_driver
      end

      def test_tap_scroll
        skip if @driver.dialect == :oss

        el = @@core.wait { @driver.find_element(:accessibility_id, 'Views') }
        @driver.action.click(el).perform

        el = @@core.wait { @driver.find_element(:accessibility_id, 'Custom') }

        rect1 = el.rect.dup
        @driver
          .action
          .move_to(el)
          .pointer_down(:left)
          .move_to_location(0, rect1.y - rect1.height)
          .release
          .perform
        assert rect1.y > el.rect.y

        rect2 = el.rect.dup
        @driver
          .action
          .move_to_location(rect2.x, rect2.y)
          .pointer_down(:left)
          .move_to_location(0, rect2.y - rect2.height * 3) # gone the element
          .release
          .perform

        @driver.manage.timeouts.implicit_wait = 3

        if @@core.automation_name == :espresso
          # Skip in espresso, since espresso show a target element in recyclerview even it is out of the view
        else
          assert_raises ::Selenium::WebDriver::Error::NoSuchElementError do
            @driver.find_element(:accessibility_id, 'Custom')
          end
        end
        @driver.manage.timeouts.implicit_wait = @@core.default_wait

        el = @@core.wait { @driver.find_element(:accessibility_id, 'ImageButton') }
        assert_equal 'ImageButton', el.text
      end

      def test_double_tap
        skip if @driver.dialect == :oss

        el = @@core.wait { @driver.find_element(:accessibility_id, 'Views') }
        @driver.action.click(el).perform

        el = @@core.wait { @driver.find_element(:accessibility_id, 'Buttons') }
        @driver.action.click(el).perform

        el = @driver.find_element(:id, 'io.appium.android.apis:id/button_toggle')
        assert_equal 'OFF', el.text
        @driver.action.click(el).perform

        assert_equal 'ON', el.text

        # double tap action with pause
        action_builder = @driver.action
        input = action_builder.pointer_inputs[0]
        action_builder
          .move_to(el)
          .pointer_down(:left)
          .pause(input, 0.05) # seconds
          .pointer_up(:left)
          .pause(input, 0.05) # seconds
          .pointer_down(:left)
          .pause(input, 0.05) # seconds
          .pointer_up(:left)
          .perform
        assert_equal 'ON', el.text

        if @@core.automation_name == :espresso
          # Skip in espresso, since espresso brings the target element in the view on recyclerview even it is out of the view
        else
          error = assert_raises ::Selenium::WebDriver::Error::UnknownError do
            @driver.action.double_click(el).perform
          end
          assert error.message.include?('You cannot perform')
        end
      end

      def test_actions_with_many_down_up
        skip if @driver.dialect == :oss

        el = @@core.wait { @driver.find_element(:accessibility_id, 'Views') }
        @driver.action.click_and_hold(el).release.perform

        el = @@core.wait { @driver.find_element(:accessibility_id, 'Custom') }

        rect1 = el.rect.dup

        if @@core.automation_name == :espresso
          _espresso_do_actions_with_many_down_up el, rect1
        else
          _uiautomator2_do_actions_with_many_down_up el, rect1
        end
      end

      def _espresso_do_actions_with_many_down_up(element, rect)
        @driver
          .action
          .move_to(element)
          .pointer_down(:left) # should insert pause
          .pointer_down(:left)
          .pointer_down(:left)
          .move_to_location(0, rect.y - rect.height)
          .release
          .release
          .perform
      end

      def _uiautomator2_do_actions_with_many_down_up(element, rect)
        error = assert_raises ::Selenium::WebDriver::Error::UnknownError do
          @driver
            .action
            .move_to(element)
            .pointer_down(:left) # should insert pause
            .pointer_down(:left)
            .pointer_down(:left)
            .move_to_location(0, rect.y - rect.height)
            .release
            .release
            .perform
        end
        assert error.message.include?('You cannot perform')
      end

      # Note: Works with Espresso Driver
      def test_multiple_actions
        f1 = @driver.action.add_pointer_input(:touch, 'finger1')
        f1.create_pointer_move(duration: 1, x: 200, y: 500,
                               origin: ::Selenium::WebDriver::Interactions::PointerMove::VIEWPORT)
        f1.create_pointer_down(:left)
        f1.create_pause(0.5)
        f1.create_pointer_move(duration: 1, x: 200, y: 200,
                               origin: ::Selenium::WebDriver::Interactions::PointerMove::VIEWPORT)
        f1.create_pointer_up(:left)

        f2 = @driver.action.add_pointer_input(:touch, 'finger2')
        f2.create_pointer_move(duration: 1, x: 200, y: 500,
                               origin: ::Selenium::WebDriver::Interactions::PointerMove::VIEWPORT)
        f2.create_pointer_down(:left)
        f2.create_pause(0.5)
        f2.create_pointer_move(duration: 1, x: 200, y: 800,
                               origin: ::Selenium::WebDriver::Interactions::PointerMove::VIEWPORT)
        f2.create_pointer_up(:left)

        @driver.perform_actions [f1, f2]
      end
    end
  end
end
# rubocop:enable Style/ClassVars
