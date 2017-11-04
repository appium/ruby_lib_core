require 'test_helper'

# $ rake test:func:ios TEST=test/functional/ios/patch_test.rb
class AppiumLibCoreTest
  class PathTest < Minitest::Test
    def setup
      @@core ||= ::Appium::Core.for(self, Caps::IOS_OPS)
      @@driver ||= @@core.start_driver
    end

    def test_value
      e = @@core.wait { @@driver.find_element :accessibility_id, 'Buttons' }

      assert_equal 'Buttons', e.value
    end

    def test_name
      e = @@core.wait { @@driver.find_element :accessibility_id, 'Buttons' }

      assert_equal 'Buttons', e.name
    end

    def test_label
      e = @@core.wait { @@driver.find_element :accessibility_id, 'Buttons' }

      assert_equal 'Buttons', e.label
    end

    def test_type
      e = @@core.wait { @@driver.find_element :accessibility_id, 'TextFields' }
      e.click

      text = @@core.wait { @@driver.find_element :name, '<enter text>' }
      text.type 'hello'

      text = @@core.wait { @@driver.find_element :name, 'Normal' }

      assert_equal 'hello', text.value
      assert_equal 'Normal', text.name

      @@driver.back
    end

    def test_location_rel
      e = @@core.wait { @@driver.find_element :accessibility_id, 'TextFields' }
      location = e.location_rel(@@driver)

      assert_equal '65.5 / 375.0', location.x
      assert_equal '196.5 / 667.0', location.y
    end
  end
end
