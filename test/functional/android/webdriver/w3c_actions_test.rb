require 'test_helper'

# $ rake test:func:android TEST=test/functional/android/webdriver/w3c_actions_test.rb
# rubocop:disable Style/ClassVars
class AppiumLibCoreTest
  module WebDriver
    class W3CActionsTest < AppiumLibCoreTest::Function::TestCase
      def setup
        @@core ||= ::Appium::Core.for(self, Caps::ANDROID_OPS)
        @@driver ||= @@core.start_driver

        @@driver.start_activity app_package: 'io.appium.android.apis',
                                app_activity: '.ApiDemos'
      end

      def teardown
        save_reports(@@driver)
      end

      def test_tap
        skip if @@driver.dialect == :oss

        el = @@core.wait { @@driver.find_element(:accessibility_id, 'Views') }
        @@driver.action.click(el).perform

        el = @@core.wait { @@driver.find_element(:accessibility_id, 'Custom') }
        # same as @@driver.action.click_and_hold(el).move_to_location(0, 700).release.perform

        rect = el.rect
        @@driver
          .action
          .move_to(el)
          .pointer_down(:left)
          .move_to_location(0, rect.y - rect.height)
          .release.perform
        assert rect.y > el.rect.y

        # Scroll a bit without elements
        rect = el.rect
        @@driver
          .action
          .move_to_location(rect.x, rect.y)
          .pointer_down(:left)
          .move_to_location(0, rect.y - rect.height)
          .release.perform
        assert rect.y > el.rect.y

        el = @@core.wait { @@driver.find_element(:accessibility_id, 'ImageButton') }
        assert_equal 'ImageButton', el.name
      end
    end
  end
end
