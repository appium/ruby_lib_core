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
      location = e.location_rel

      assert_equal '65.5 / 375.0', location.x # Actual: "56.0 / 320.0" ?? on iOS13?
      assert_equal '196.5 / 667.0', location.y
    end

    def test_immediate_value
      e = @@core.wait { @@driver.find_element :accessibility_id, 'TextFields' }
      e.click

      text = @@core.wait { @@driver.find_element :name, '<enter text>' }
      text.immediate_value('hello')

      text = @@core.wait { @@driver.find_element :name, 'Normal' }
      assert_equal 'hello', text.value
      assert_equal 'Normal', text.name
      @@driver.back
    end
  end
end
# rubocop:enable Style/ClassVars
