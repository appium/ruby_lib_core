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
            @core ||= ::Appium::Core.for(self, Caps.android)
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
              .move_to(::Selenium::WebDriver::Element.new(@driver.send(:bridge), 'id'))
              .pointer_down(:left)
              .move_to_location(0, 10 - 5)
              .release.perform

            assert_requested(:post, "#{SESSION}/actions", times: 1)
          end
        end # class CommandsTest
      end # module W3C
    end # module WebDriver
  end # module Android
end # class AppiumLibCoreTest
