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
        @@core.quit_driver
      end

      def test_uiautomation
        skip 'Espresso does not support uiautomator' if @@core.automation_name == :espresso

        e = @driver.find_elements :uiautomator, 'new UiSelector().clickable(true)'

        assert e.size > 10
      end

      def test_viewtag
        skip 'UiAutomator2 does not support viewtag' if @@core.automation_name != :espresso

        e = @driver.find_elements :viewtag, 'example'
        assert_equal 0, e.size
      end

      def test_datamatcher
        skip 'UiAutomator2 does not support viewtag' if @@core.automation_name != :espresso

        e = @driver.find_elements :data_matcher, { name: 'hasEntry', args: %w(title Animation) }
        assert_equal 1, e.size

        e.click
        @driver.find_element :accessibility_id, 'Cloning' # no error
        @driver.back
      end
    end
  end
end
# rubocop:enable Style/ClassVars
