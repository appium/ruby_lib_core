require 'test_helper'

# $ rake test:func:android TEST=test/functional/android/android/search_context_test.rb
# rubocop:disable Style/ClassVars
class AppiumLibCoreTest
  module Ios
    class SearchContextTest < Minitest::Test
      def setup
        @@core ||= ::Appium::Core.for(self, Caps::ANDROID_OPS)
        @@driver ||= @@core.start_driver
      end

      def test_uiautomation
        e = @@driver.find_elements :uiautomator, 'new UiSelector().clickable(true)'

        assert e.size > 10
      end
    end
  end
end
