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

# $ rake test:unit TEST=test/unit/ios/device/w3c/definition_test.rb
class AppiumLibCoreTest
  module IOS
    module Device
      module W3C
        class DefinitionTest < Minitest::Test
          include AppiumLibCoreTest::Mock

          def setup
            @core ||= ::Appium::Core.for(Caps.ios)
            @driver ||= ios_mock_create_session_w3c
          end

          def test_delegate_driver_method
            assert @driver.respond_to? :launch_app
          end

          def test_delegate_from_appium_driver
            assert @core.send(:delegated_target_for_test).respond_to? :launch_app
          end

          def delegate_from_appium_driver(key)
            assert @core.send(:delegated_target_for_test).respond_to? key
          end

          def parameterized_method_defined_check(array)
            array.each do |v|
              assert ::Appium::Core::Base::Bridge.method_defined?(v)
              delegate_from_appium_driver(v)
            end
          end

          def test_with_arg_definitions
            parameterized_method_defined_check([:shake,
                                                :launch_app,
                                                :close_app,
                                                :reset,
                                                :device_locked?,
                                                :unlock,
                                                :device_time,
                                                :current_context,
                                                :available_contexts,
                                                :set_context,
                                                :app_strings,
                                                :lock,
                                                :install_app,
                                                :remove_app,
                                                :terminate_app,
                                                :activate_app,
                                                :app_state,
                                                :app_installed?,
                                                :background_app,
                                                :hide_keyboard,
                                                :keyevent,
                                                :press_keycode,
                                                :long_press_keycode,
                                                :set_immediate_value,
                                                :push_file,
                                                :pull_file,
                                                :pull_folder,
                                                :get_clipboard,
                                                :set_clipboard,
                                                :get_settings,
                                                :update_settings,
                                                :touch_actions,
                                                :multi_touch,
                                                :touch_id,
                                                :toggle_touch_id_enrollment,
                                                :execute_driver])
          end
        end # class DefinitionTest
      end # module W3C
    end # module Device
  end # module IOS
end # class AppiumLibCoreTest
