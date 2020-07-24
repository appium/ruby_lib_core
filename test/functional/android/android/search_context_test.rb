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

      def test_uiautomator
        skip 'Espresso does not support uiautomator' if @@core.automation_name == :espresso
        assert @driver.find_element :uiautomator, 'new UiSelector().clickable(true)'
      end

      def test_viewtag
        skip 'UiAutomator2 does not support viewtag' if @@core.automation_name != :espresso

        e = @driver.find_elements :viewtag, 'example'
        assert_equal 0, e.size
      end

      def test_datamatcher
        skip 'UiAutomator2 does not support viewtag' if @@core.automation_name != :espresso

        e = @driver.find_elements :data_matcher, { name: 'hasEntry', args: %w(title Animation) }.to_json
        assert_equal 1, e.size

        e.first.click
        @driver.find_element :accessibility_id, 'Cloning' # no error
        @driver.back
      end

      def test_viewmatcher
        skip 'UiAutomator2 does not support viewtag' if @@core.automation_name != :espresso
        skip_as_appium_version('1.17.0')

        # Uses withText in 'androidx.test.espresso.matcher.ViewMatchers'
        e = @driver.find_element :view_matcher, {
          name: 'withText',
          args: ['Accessibility'],
          class: 'androidx.test.espresso.matcher.ViewMatchers'
        }.to_json
        e.click

        @driver.find_element :accessibility_id, 'Custom View'
        @driver.back

        # Multiple matchers with 'org.hamcrest.Matchers.allOf'
        # https://developer.android.com/training/testing/espresso/recipes
        # https://developer.android.com/reference/androidx/test/espresso/matcher/ViewMatchers#withsubstring
        e = @driver.find_element :view_matcher, {
          name: 'allOf',
          args: [
            {
              name: 'withSubstring',
              args: 'Acc',
              class: 'androidx.test.espresso.matcher.ViewMatchers'
            },
            {
              name: 'isDisplayed',
              class: 'androidx.test.espresso.matcher.ViewMatchers'
            },
            {
              name: 'withSubstring',
              args: "'",
              class: 'androidx.test.espresso.matcher.ViewMatchers'
            }
          ],
          class: 'org.hamcrest.Matchers'
        }.to_json
        assert_equal "Access'ibility", e.text
      end
    end
  end
end
# rubocop:enable Style/ClassVars
