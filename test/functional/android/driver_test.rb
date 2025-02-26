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

# $ rake test:func:android TEST=test/functional/android/driver_test.rb
# rubocop:disable Style/ClassVars
class AppiumLibCoreTest
  class DriverTest < AppiumLibCoreTest::Function::TestCase
    def setup
      @@core ||= ::Appium::Core.for(Caps.android)
      @driver = @@core.start_driver
    end

    def teardown
      save_reports(@driver)
      @driver&.quit
    end

    def test_appium_server_version
      v = @@core.appium_server_version

      refute_nil v['build']['version']
    end

    def test_wait_true
      e = @@core.wait_true { @driver.find_element :accessibility_id, 'Content' }
      assert e.text
    end

    def test_wait
      e = @@core.wait { @driver.find_element :accessibility_id, 'Content' }
      assert_equal 'Content', e.text
    end

    def test_wait_true_driver
      e = @driver.wait_true { |d| d.find_element :accessibility_id, 'Content' }
      assert e.text
    end

    def test_wait_driver
      e = @driver.wait { |d| d.find_element :accessibility_id, 'Content' }
      assert_equal 'Content', e.text
    end

    def test_wait_until_true_driver
      e = @driver.wait_until_true { |d| d.find_element :accessibility_id, 'Content' }
      assert e.text
    end

    def test_wait_until_driver
      e = @driver.wait_until { |d| d.find_element :accessibility_id, 'Content' }
      assert_equal 'Content', e.text
    end

    # @since Appium 1.10.0
    def test_mobile_perform_action
      skip_as_appium_version '1.10.0'
      skip 'Espresso is unstable to get attributes' if @@core.automation_name == :espresso

      @driver.find_element(:accessibility_id, 'App').click
      @driver.find_element(:accessibility_id, 'Activity').click
      @driver.find_element(:accessibility_id, 'Custom Title').click

      e = @driver.find_element :id, 'io.appium.android.apis:id/left_text_edit'
      e.click

      assert_equal 'Left is best', e.text
      assert_equal 'true', e.focused

      @driver.execute_script 'mobile: performEditorAction', { action: 'normal' }
      assert_equal 'false', e.focused

      new_element = @driver.find_element :xpath, '//*[@focused="true"]'
      assert_equal 'Right is always right', new_element.text
    end
  end
end
# rubocop:enable Style/ClassVars
