require 'test_helper'

# $ rake test:func:ios TEST=test/functional/ios/ios/search_context_test.rb
# rubocop:disable Style/ClassVars
class AppiumLibCoreTest
  module Ios
    class SearchContextTest < AppiumLibCoreTest::Function::TestCase
      def setup
        @@core ||= ::Appium::Core.for(Caps.ios)
        @@driver ||= @@core.start_driver
      end

      def teardown
        save_reports(@@driver)
      end

      def test_uiautomation
        if @@core.automation_name != :xcuitest
          e = @@driver.find_element :predicate, 'wdName == "Buttons"'
          assert !e.name.nil?
        else
          assert true
        end
      end

      def test_predicate
        e = @@driver.find_element :predicate, 'wdName == "Buttons"'
        assert_equal 'Buttons', e.name
      end

      def test_class_chain
        skip 'Only for XCUITest'  unless @@core.automation_name == :xcuitest

        e = @@driver.find_element :class_chain, "**/XCUIElementTypeWindow[$name == 'Buttons'$]"
        assert_equal 'XCUIElementTypeWindow', e.tag_name
      end
    end
  end
end
# rubocop:enable Style/ClassVars
