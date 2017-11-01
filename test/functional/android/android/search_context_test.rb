require 'test_helper'

# $ rake android TEST=test/android/android/search_context_test.rb
class AppiumLibCoreTest
  module Ios
    class SearchContextTest < Minitest::Test
      def setup
        @@core ||= ::Appium::Core.for(self, Caps::ANDROID_OPS)
        @@driver ||= @@core.start_driver
      end

      def test_uiautomation
        e = @@driver.find_elements :uiautomator, 'new UiSelector().clickable(true)'

        assert 10 < e.size
      end
    end
  end
end
