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

# $ rake test:unit TEST=test/unit/android/device/mjsonwp/definition_test.rb
class AppiumLibCoreTest
  module Android
    module Device
      module MJSONWP
        class DefinitionTest < Minitest::Test
          include AppiumLibCoreTest::Mock

          def setup
            @core ||= ::Appium::Core.for(Caps.android)
            @driver ||= android_mock_create_session
          end

          def test_delegate_driver_method
            assert @driver.respond_to? :launch_app
          end

          def delegate_from_appium_driver(key)
            assert @core.send(:delegated_target_for_test).respond_to? key
          end

          def parameterized_method_defined_check(array)
            array.each do |v|
              assert ::Appium::Core::Base::Bridge::MJSONWP.method_defined?(v)
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
                                                :open_notifications,
                                                :toggle_airplane_mode,
                                                :current_activity,
                                                :current_package,
                                                :get_system_bars,
                                                :get_display_density,
                                                :is_keyboard_shown,
                                                :get_network_connection,
                                                :get_performance_data_types,
                                                :available_contexts,
                                                :set_context,
                                                :app_strings,
                                                :lock,
                                                :install_app,
                                                :remove_app,
                                                :app_installed?,
                                                :terminate_app,
                                                :activate_app,
                                                :app_state,
                                                :background_app,
                                                :hide_keyboard,
                                                :keyevent,
                                                :press_keycode,
                                                :long_press_keycode,
                                                :take_element_screenshot,
                                                :set_immediate_value,
                                                :replace_value,
                                                :push_file,
                                                :pull_file,
                                                :pull_folder,
                                                :get_settings,
                                                :update_settings,
                                                :touch_actions,
                                                :multi_touch,
                                                :start_activity,
                                                :end_coverage,
                                                :set_network_connection,
                                                :get_performance_data,
                                                :get_clipboard,
                                                :set_clipboard,
                                                :execute_driver,
                                                :chromium_network_conditions,
                                                :chromium_network_conditions=,
                                                :chromium_available_log_types,
                                                :chromium_log,
                                                :chromium_send_cdp_command])
          end
        end
      end # module MJSONWP
    end # module Device
  end # module Android
end # class AppiumLibCoreTest
