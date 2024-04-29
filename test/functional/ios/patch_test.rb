# frozen_string_literal: true

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'test_helper'
require 'functional/common_w3c_actions'

# $ rake test:func:ios TEST=test/functional/ios/patch_test.rb
# rubocop:disable Style/ClassVars
class AppiumLibCoreTest
  class PathTest < AppiumLibCoreTest::Function::TestCase
    def setup
      @@core = ::Appium::Core.for(Caps.ios)
      @@driver = @@core.start_driver
    end

    def teardown
      save_reports(@@driver)
    end

    def test_method_missing_attributes
      e = @@core.wait { @@driver.find_element :accessibility_id, 'Buttons' }

      assert_equal 'Buttons', e.value
      assert_equal 'Buttons', e.name
      assert_equal 'Buttons', e.label
    end

    def test_type
      w3c_scroll @@driver

      @@core.wait { @@driver.find_element :accessibility_id, 'Text Fields' }.click

      text = @@core.wait { @@driver.find_element :class, 'XCUIElementTypeTextField' }
      text.type 'hello'

      e = @@core.wait { @@driver.find_element :predicate, 'value == "hello"' }
      assert_equal 'hello', e.value

      @@driver.back
    end

    def test_location_rel
      e = @@core.wait { @@driver.find_element :accessibility_id, 'Date Picker' }
      location = e.location_rel @@driver

      expected_x, expected_y = if over_ios17?(@@driver)
                                 # iPhone 15 Plus
                                 ['64.0 / 430.0', '245.0 / 932.0']
                               elsif over_ios14?(@@driver)
                                 # iPhone 11
                                 ['64.0 / 414.0', '239.5 / 896.0']
                               elsif over_ios13?(@@driver)
                                 # iPhone 11
                                 ['64.0 / 414.0', '235.5 / 896.0']
                               else
                                 ['74.5 / 414.0', '411.0 / 896.0']
                               end

      assert_equal expected_x, location.x, "Expected X is #{expected_x}, actual is #{location.x}"
      assert_equal expected_y, location.y, "Expected y is #{expected_y}, actual is #{location.y}"
    end
  end
end
# rubocop:enable Style/ClassVars
