require 'test_helper'

# $ rake test:func:android TEST=test/functional/android/android/search_context_test.rb
# rubocop:disable Style/ClassVars
class AppiumLibCoreTest
  module Android
    class SearchContextTest < AppiumLibCoreTest::Function::TestCase
      def setup
        @@core ||= ::Appium::Core.for(Caps.android)
        @driver = @@core.start_driver
      end

      def teardown
        save_reports(@driver)
      end

      def test_uiautomation
        e = @driver.find_elements :uiautomator, 'new UiSelector().clickable(true)'

        assert e.size > 10
      end
    end
  end
end
