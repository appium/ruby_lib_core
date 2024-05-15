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
        skip_as_appium_version '1.8.0'

        el = @@core.wait { @@driver.find_element(:accessibility_id, 'Buttons') }
        @@driver.action.click(el).perform

        # require 'pry'
        # binding.pry
        #
        button_label = if over_ios17? @@driver
                         'X Button'
                       elsif over_ios13? @@driver
                         'X'
                       else
                         'X Button'
                       end

        el = @@core.wait { @@driver.find_element(:name, button_label) }
        rect = el.rect
        @@driver.action.click_and_hold(el).move_to_location(rect.x, rect.y + 500).release.perform
      end

      def test_scroll
        skip_as_appium_version '1.8.0'

        el = @@core.wait { @@driver.find_element(:accessibility_id, 'Segmented Controls') }
        @@driver.action.click(el).perform

        [1, 2, 3].each do |count|
          el = @@driver.find_element(:accessibility_id, 'TINTED')
          rect = el.rect

          @@driver.execute_script('mobile: scroll', direction: 'down')

          break if el.rect.y <= rect.y

          # fail
          assert false if count == 3
        end
        assert true
      end

      def test_scroll2
        skip_as_appium_version '1.9.0' # fix scroll actions

        el = @@core.wait { @@driver.find_element(:accessibility_id, 'Segmented Controls') }
        @@driver.action.click(el).perform

        el = @@core.wait { @@driver.find_element(:accessibility_id, 'TINTED') }
        rect = el.rect

        w3c_scroll @@driver

        assert el.rect.y <= rect.y
      end

      def test_click_w3c_landscape
        @@driver.rotation = :landscape

        el = @@driver.find_element :name, 'Buttons'
        # iOS 16 simulator returned wrong coordinate.
        # @@driver.action.click(el).perform
        el.click

        # The view has two views
        els_land = @@driver.find_elements :name, 'Buttons'
        els_land_length = els_land.length
        @@driver.rotation = :portrait

        # The view has only one view
        els_port = @@driver.find_elements :name, 'Buttons'

        assert els_land_length > els_port.length
      end
    end
  end
end
# rubocop:enable Style/ClassVars
