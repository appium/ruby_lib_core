require 'test_helper'

# $ rake test:func:ios TEST=test/functional/ios/webdriver/w3c_actions_test.rb
# rubocop:disable Style/ClassVars
class AppiumLibCoreTest
  module WebDriver
    class W3CActionsTest < AppiumLibCoreTest::Function::TestCase
      def setup
        @@core ||= ::Appium::Core.for(Caps.ios)
        @@driver = @@core.start_driver
      end

      def teardown
        save_reports(@@driver)
      end

      def test_tap
        skip if @@driver.dialect == :oss

        el = @@core.wait { @@driver.find_element(:accessibility_id, 'Buttons') }
        @@driver.action.click(el).perform

        el = @@core.wait { @@driver.find_element(:name, 'Button with Image') }
        rect = el.rect
        @@driver.action.click_and_hold(el).move_to_location(rect.x, rect.y + 500).release.perform
      end

      def test_scroll
        el = @@core.wait { @@driver.find_element(:accessibility_id, 'Controls') }
        @@driver.action.click(el).perform

        [1, 2, 3, 4, 5].each do |_value|
          el = @@core.wait do
            @@driver.find_element(:xpath, "//XCUIElementTypeStaticText[@name='Style Default']/parent::*")
          end
          visibility = el.visible
          break if visibility == 'true'

          @@driver.execute_script('mobile: scroll', direction: 'down')
        end
      end
    end
  end
end
# rubocop:enable Style/ClassVars
