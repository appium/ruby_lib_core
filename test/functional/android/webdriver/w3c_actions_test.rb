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
      end

      def test_tap
        skip if @driver.dialect == :oss

        el = @@core.wait { @driver.find_element(:accessibility_id, 'Views') }
        @driver.action.click(el).perform

        el = @@core.wait { @driver.find_element(:accessibility_id, 'Custom') }
        # same as @driver.action.click_and_hold(el).move_to_location(0, 700).release.perform

        rect = el.rect
        @driver
          .action
          .move_to(el)
          .pointer_down(:left)
          .move_to_location(0, rect.y - rect.height)
          .release.perform
        assert rect.y > el.rect.y

        # Scroll a bit without elements
        rect = el.rect
        @driver
          .action
          .move_to_location(rect.x, rect.y)
          .pointer_down(:left)
          .move_to_location(0, rect.y - rect.height)
          .release.perform
        assert rect.y > el.rect.y

        el = @@core.wait { @driver.find_element(:accessibility_id, 'ImageButton') }
        assert_equal 'ImageButton', el.text
      end

      def test_multiple_actions
        f1 = @driver.action.add_pointer_input(:touch, 'finger1')
        f1.create_pointer_move(duration: 0.5, x: 100, y: 100, origin: ::Selenium::WebDriver::Interactions::PointerMove::VIEWPORT )
        f1.create_pointer_down(:left)
        f1.create_pointer_move(duration: 1, x: 0, y: 100, origin: ::Selenium::WebDriver::Interactions::PointerMove::VIEWPORT )
        f1.create_pointer_up(:left)

        f2 = @driver.action.add_pointer_input(:touch, 'finger2')
        f2.create_pointer_move(duration: 0.5, x: 100, y: 100, origin: ::Selenium::WebDriver::Interactions::PointerMove::VIEWPORT )
        f2.create_pointer_down(:left)
        f2.create_pointer_move(duration: 1, x: 200, y: 100, origin: ::Selenium::WebDriver::Interactions::PointerMove::VIEWPORT )
        f2.create_pointer_up(:left)

        require 'pry'
        binding.pry

        @driver.send_actions [f1, f2]
      end
    end
  end
end
