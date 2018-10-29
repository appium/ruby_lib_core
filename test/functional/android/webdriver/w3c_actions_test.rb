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

      def test_tap
        skip if @driver.dialect == :oss

        el = @@core.wait { @driver.find_element(:accessibility_id, 'Views') }
        @driver.action.click(el).perform

        el = @@core.wait { @driver.find_element(:accessibility_id, 'Custom') }
        # same as @driver.action.click_and_hold(el).move_to_location(0, 700).release.perform

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
          .move_to_location(0, rect2.y - rect2.height * 2)
          .release
          .perform
        assert rect2.y > el.rect.y

        el = @@core.wait { @driver.find_element(:accessibility_id, 'ImageButton') }
        assert_equal 'ImageButton', el.text
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
