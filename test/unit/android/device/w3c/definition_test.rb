require 'test_helper'
require 'webmock/minitest'

# $ rake test:unit TEST=test/unit/android/device_test.rb
class AppiumLibCoreTest
  module Android
    module Device
      module W3C
        class DefinitionTest < Minitest::Test
          include AppiumLibCoreTest::Mock

          def setup
            @core ||= ::Appium::Core.for(self, Caps::ANDROID_OPS)
            @driver ||= android_mock_create_session_w3c
          end

          def parameterized_method_defined_check(array)
            array.each { |v| assert ::Appium::Core::Base::Bridge::W3C.method_defined?(v) }
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
                                                :set_clipboard])
          end
        end # class DefinitionTest
      end # module W3C
    end # module Device
  end # module Android
end # class AppiumLibCoreTest
