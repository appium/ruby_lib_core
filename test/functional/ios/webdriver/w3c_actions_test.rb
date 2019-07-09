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

# $ rake test:func:ios TEST=test/functional/ios/webdriver/w3c_actions_test.rb
# rubocop:disable Style/ClassVars
class AppiumLibCoreTest
  module WebDriver
    class W3CActionsTest < AppiumLibCoreTest::Function::TestCase
      def setup
        @@core = ::Appium::Core.for(Caps.ios)
        @@driver = @@core.start_driver
      end

      def teardown
        save_reports(@@driver)
      end

      def test_tap
        skip if @@driver.dialect == :oss
        skip_as_appium_version '1.8.0'

        el = @@core.wait { @@driver.find_element(:accessibility_id, 'Buttons') }
        @@driver.action.click(el).perform

        el = @@core.wait { @@driver.find_element(:name, 'Button with Image') }
        rect = el.rect
        @@driver.action.click_and_hold(el).move_to_location(rect.x, rect.y + 500).release.perform
      end

      def test_scroll
        skip if @@driver.dialect == :oss
        skip_as_appium_version '1.8.0'

        el = @@core.wait { @@driver.find_element(:accessibility_id, 'Controls') }
        @@driver.action.click(el).perform

        [1, 2, 3, 4, 5].each do |_value|
          el = @@core.wait do
            @@driver.find_element(:xpath, "//XCUIElementTypeStaticText[@name='Style Default']/parent::*")
          end
          visibility = el.visible
          break if visibility == 'true'

          @@driver.execute_script('mobile: scroll', direction: 'down')
        end
      end

      def test_scroll2
        skip if @@driver.dialect == :oss
        skip_as_appium_version '1.9.0' # fix scroll actions

        el = @@core.wait { @@driver.find_element(:accessibility_id, 'Controls') }
        @@driver.action.click(el).perform

        el = @@core.wait { @@driver.find_element(:accessibility_id, 'Style Gray') }
        assert el.visible == 'false'

        w3c_scroll @@driver

        el = @@core.wait { @@driver.find_element(:accessibility_id, 'Style Gray') }
        assert el.visible == 'true'
      end
    end
  end
end
# rubocop:enable Style/ClassVars
