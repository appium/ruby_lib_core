require 'test_helper'

# $ rake test:func:android TEST=test/functional/android/patch_test.rb
# rubocop:disable Style/ClassVars
class AppiumLibCoreTest
  class PathTest < AppiumLibCoreTest::Function::TestCase
    def setup
      @@core ||= ::Appium::Core.for(self, Caps::ANDROID_OPS)
      @@driver ||= @@core.start_driver

      @@driver.start_activity app_package: 'io.appium.android.apis',
                              app_activity: '.ApiDemos'
    end

    def teardown
      cleanup(@@driver)
    end

    def test_value
      skip "Android doesn't support"
      e = @@core.wait { @@driver.find_element :accessibility_id, 'App' }

      assert_equal 'App', e.value
    end

    def test_name
      skip "Android doesn't support"
      e = @@core.wait { @@driver.find_element :accessibility_id, 'App' }

      assert_equal 'App', e.name
    end

    def test_label
      skip "Android doesn't support"
      e = @@core.wait { @@driver.find_element :accessibility_id, 'App' }

      assert_equal 'App', e.label
    end

    def test_type
      @@core.wait { @@driver.find_element :accessibility_id, 'App' }.click
      @@core.wait { @@driver.find_element :accessibility_id, 'Activity' }.click
      @@core.wait { @@driver.find_element :accessibility_id, 'Custom Title' }.click

      @@core.wait { @@driver.find_element :id, 'io.appium.android.apis:id/left_text_edit' }.type 'Pökémön'

      text = @@core.wait { @@driver.find_element :id, 'io.appium.android.apis:id/left_text_edit' }
      assert_equal 'Left is bestPökémön', text.name
    end

    def test_location_rel
      e = @@core.wait { @@driver.find_element :accessibility_id, 'App' }
      location = e.location_rel(@@driver)

      assert_match %r{\A[0-9]+\.[0-9]+ \/ [0-9]+\.[0-9]+\z}, location.x
      assert_match %r{\A[0-9]+\.[0-9]+ \/ [0-9]+\.[0-9]+\z}, location.y
    end
  end
end
