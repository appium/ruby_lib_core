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

# $ rake test:func:ios TEST=test/functional/ios/driver_test.rb
# rubocop:disable Style/ClassVars
class AppiumLibCoreTest
  class DriverTest < AppiumLibCoreTest::Function::TestCase
    def setup
      @@core = ::Appium::Core.for(Caps.ios)
      @@driver = @@core.start_driver
    end

    def teardown
      save_reports(@@driver)
    end

    def test_appium_server_version
      v = @@core.appium_server_version

      refute_nil v['build']['version']
    end

    def test_platform_version
      assert_equal [12, 1], @@core.platform_version
    end

    def test_screenshot
      file = @@core.screenshot 'ios_test.png'

      assert File.exist?(file.path)

      File.delete file.path
      assert !File.exist?(file.path)
    end

    def test_wait_true
      e = @@core.wait_true { @@driver.find_element :accessibility_id, 'UICatalog' }
      assert e.name
    end

    def test_wait
      e = @@core.wait { @@driver.find_element :accessibility_id, 'UICatalog' }
      assert_equal 'UICatalog', e.name
    end

    def test_click_back
      e = @@driver.find_element :accessibility_id, 'Alerts'
      e.click
      sleep 1 # wait for animation
      error = assert_raises do
        e.click
      end
      assert [::Selenium::WebDriver::Error::UnknownError,
              ::Selenium::WebDriver::Error::ElementNotVisibleError,
              ::Selenium::WebDriver::Error::InvalidSelectorError].include? error.class
      assert error.message.include? ' is not visible on the screen and thus is not interactable'
      @@driver.back
    end

    # @since Appium 1.14.0
    def test_default_keyboard_pref
      skip 'til WDA 0.0.6 will be released'

      bundle_id = @@driver.session_capabilities['CFBundleIdentifier']
      begin
        @@driver.activate_app('com.apple.Preferences')
        @@driver.find_element(:accessibility_id, 'General').click
        @@driver.find_element(:accessibility_id, 'Keyboard').click

        eles = @@driver.find_elements :class, 'XCUIElementTypeSwitch'
        switches_status = eles.each_with_object({}) { |e, acc| acc[e.name] = e.value }
      ensure
        @@driver.activate_app(bundle_id)
      end
      assert_equal '0', switches_status['Auto-Correction']
      assert_equal '0', switches_status['Predictive']
    end

    # TODO: call @driver.quit after tests
  end
end
# rubocop:enable Style/ClassVars
