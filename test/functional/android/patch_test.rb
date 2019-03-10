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

# $ rake test:func:android TEST=test/functional/android/patch_test.rb
# rubocop:disable Style/ClassVars
class AppiumLibCoreTest
  class PathTest < AppiumLibCoreTest::Function::TestCase
    def setup
      @@core ||= ::Appium::Core.for(Caps.android)
      @driver = @@core.start_driver # Launch test servers without calling delete session before a new create session
    end

    def teardown
      save_reports(@driver)
    end

    def test_method_missing_attributes
      e = @@core.wait { @driver.find_element :accessibility_id, 'App' }

      assert_equal 'App', e.text
      assert_equal 'false', e.focused
    end

    def test_type
      @@core.wait { @driver.find_element :accessibility_id, 'App' }.click
      @@core.wait { @driver.find_element :accessibility_id, 'Activity' }.click
      @@core.wait { @driver.find_element :accessibility_id, 'Custom Title' }.click

      @@core.wait { @driver.find_element :id, 'io.appium.android.apis:id/left_text_edit' }.type 'Pökémön'

      text = @@core.wait { @driver.find_element :id, 'io.appium.android.apis:id/left_text_edit' }
      assert_equal 'Left is bestPökémön', text.text
    end

    def test_location_rel
      e = @@core.wait { @driver.find_element :accessibility_id, 'App' }
      location = e.location_rel(@driver)

      assert_match %r{\A[0-9]+\.[0-9]+ \/ [0-9]+\.[0-9]+\z}, location.x
      assert_match %r{\A[0-9]+\.[0-9]+ \/ [0-9]+\.[0-9]+\z}, location.y
    end
  end
end
# rubocop:enable Style/ClassVars
