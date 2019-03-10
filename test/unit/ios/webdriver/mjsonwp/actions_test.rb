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
require 'webmock/minitest'

# $ rake test:unit TEST=test/unit/android/webdriver/w3c/actions_test.rb
class AppiumLibCoreTest
  module IOS
    module WebDriver
      module MJSONWP
        class ActionsTest < Minitest::Test
          include AppiumLibCoreTest::Mock

          def setup
            @core ||= ::Appium::Core.for(Caps.android)
            @driver ||= android_mock_create_session_w3c
          end

          def test_press_touch_action
            action = Appium::Core::TouchAction.new(@driver).press(
              element: ::Selenium::WebDriver::Element.new(@driver.send(:bridge), 'id')
            ).release

            assert_equal [{ action: :press, options: { element: 'id' } }, { action: :release }], action.actions

            stub_request(:post, "#{SESSION}/touch/perform")
              .with(body: { actions: [{ action: :press, options: { element: 'id' } }, { action: :release }] }.to_json)
              .to_return(headers: HEADER, status: 200, body: { value: nil }.to_json)

            action.perform
            assert_equal [], action.actions
          end

          def test_press_touch_action_with_force
            action = Appium::Core::TouchAction.new(@driver).press(
              element: ::Selenium::WebDriver::Element.new(@driver.send(:bridge), 'id'),
              pressure: 1.0
            ).release

            assert_equal [{ action: :press, options: { element: 'id', pressure: 1.0 } }, { action: :release }], action.actions

            stub_request(:post, "#{SESSION}/touch/perform")
              .with(body:
                { actions: [{ action: :press, options: { element: 'id', pressure: 1.0 } }, { action: :release }] }.to_json)
              .to_return(headers: HEADER, status: 200, body: { value: nil }.to_json)

            action.perform
            assert_equal [], action.actions
          end
        end # class CommandsTest
      end # module W3C
    end # module WebDriver
  end # module Android
end # class AppiumLibCoreTest
