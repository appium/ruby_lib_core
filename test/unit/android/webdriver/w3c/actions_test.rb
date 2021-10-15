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
  module Android
    module WebDriver
      module W3C
        class ActionsTest < Minitest::Test
          include AppiumLibCoreTest::Mock

          def setup
            @core ||= ::Appium::Core.for(Caps.android)
            @driver ||= android_mock_create_session_w3c
          end

          def test_w3c_actions
            action_body = {
              actions: [{
                type: 'pointer',
                id: 'mouse',
                actions: [{
                  type: 'pointerMove',
                  duration: 50,
                  x: 0,
                  y: 0,
                  origin: {
                    'element-6066-11e4-a52e-4f735466cecf' => 'id'
                  }
                }, {
                  type: 'pointerDown',
                  button: 0
                }, {
                  type: 'pointerMove',
                  duration: 50,
                  x: 0,
                  y: 5,
                  origin: 'viewport'
                }, {
                  type: 'pointerUp',
                  button: 0
                }],
                parameters: {
                  pointerType: 'mouse'
                }
              }]
            }

            stub_request(:post, "#{SESSION}/actions")
              .with(body: action_body.to_json)
              .to_return(headers: HEADER, status: 200, body: { value: nil }.to_json)

            @driver
              .action
              .move_to(::Appium::Core::Element.new(@driver.send(:bridge), 'id'))
              .pointer_down(:left)
              .move_to_location(0, 10 - 5)
              .release.perform

            assert_requested(:post, "#{SESSION}/actions", times: 1)
          end

          def test_w3c_actions_send_keys_active_element
            action_body = {
              actions: [{
                type: 'key',
                id: 'keyboard',
                actions: [{
                  type: 'keyDown',
                  value: 'h'
                }, {
                  type: 'keyUp',
                  value: 'h'
                }, {
                  type: 'keyDown',
                  value: 'i'
                }, {
                  type: 'keyUp',
                  value: 'i'
                }, {
                  type: 'keyDown',
                  value: 'あ'
                }, {
                  type: 'keyUp',
                  value: 'あ'
                }]
              }]
            }

            stub_request(:post, "#{SESSION}/actions")
              .with(body: action_body.to_json)
              .to_return(headers: HEADER, status: 200, body: { value: nil }.to_json)

            @driver
              .action
              .send_keys('hiあ')
              .perform

            assert_requested(:post, "#{SESSION}/actions", times: 1)
          end

          def test_w3c__multiple_actions
            action_body = {
              actions: [{
                type: :pointer,
                id: 'finger1',
                actions: [
                  { type: :pointerMove, duration: 50, x: 100, y: 100, origin: 'viewport' },
                  { type: :pointerDown, button: 0 },
                  { type: :pause, duration: 50 },
                  { type: :pointerMove, duration: 50, x: 50, y: 100, origin: 'viewport' },
                  { type: :pointerUp, button: 0 }
                ],
                parameters: { pointerType: :touch }
              }, {
                type: :pointer,
                id: 'finger2',
                actions: [
                  { type: :pointerMove, duration: 50, x: 100, y: 100, origin: 'viewport' },
                  { type: :pointerDown, button: 0 },
                  { type: :pause, duration: 50 },
                  { type: :pointerMove, duration: 50, x: 150, y: 100, origin: 'viewport' },
                  { type: :pointerUp, button: 0 }
                ],
                parameters: { pointerType: :touch }
              }]
            }

            stub_request(:post, "#{SESSION}/actions")
              .with(body: action_body.to_json)
              .to_return(headers: HEADER, status: 200, body: { value: nil }.to_json)

            f1 = @driver.action.add_pointer_input(:touch, 'finger1')
            f1.create_pointer_move(duration: 0.05, x: 100, y: 100,
                                   origin: ::Selenium::WebDriver::Interactions::PointerMove::VIEWPORT)
            f1.create_pointer_down(:left)
            f1.create_pause(0.05)
            f1.create_pointer_move(duration: 0.05, x: 50, y: 100,
                                   origin: ::Selenium::WebDriver::Interactions::PointerMove::VIEWPORT)
            f1.create_pointer_up(:left)

            f2 = @driver.action.add_pointer_input(:touch, 'finger2')
            f2.create_pointer_move(duration: 0.05, x: 100, y: 100,
                                   origin: ::Selenium::WebDriver::Interactions::PointerMove::VIEWPORT)
            f2.create_pointer_down(:left)
            f2.create_pause(0.05)
            f2.create_pointer_move(duration: 0.05, x: 150, y: 100,
                                   origin: ::Selenium::WebDriver::Interactions::PointerMove::VIEWPORT)
            f2.create_pointer_up(:left)

            @driver.perform_actions [f1, f2]

            assert_requested(:post, "#{SESSION}/actions", times: 1)
            assert_equal [], f1.actions
            assert_equal [], f2.actions
          end

          def test_w3c__multiple_actions_no_array
            error = assert_raises ::Appium::Core::Error::ArgumentError do
              @driver.perform_actions 'string'
            end
            assert_equal '\'string\' must be Array', error.message
          end

          def test_press_touch_action
            action = Appium::Core::TouchAction.new(@driver).press(
              element: ::Appium::Core::Element.new(@driver.send(:bridge), 'id')
            ).release

            assert_equal [{ action: :press, options: { element: 'id' } }, { action: :release }], action.actions

            stub_request(:post, "#{SESSION}/touch/perform")
              .with(body: { actions: [{ action: :press, options: { element: 'id' } }, { action: :release }] }.to_json)
              .to_return(headers: HEADER, status: 200, body: { value: nil }.to_json)

            action.perform
            assert_equal [], action.actions
          end
        end # class CommandsTest
      end # module W3C
    end # module WebDriver
  end # module Android
end # class AppiumLibCoreTest
