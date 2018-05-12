require 'test_helper'
require 'webmock/minitest'

# $ rake test:unit TEST=test/unit/ios/device_test.rb
class AppiumLibCoreTest
  module IOS
    module Device
      module W3C
        class DefinitionTest < Minitest::Test
          include AppiumLibCoreTest::Mock

          def setup
            @core ||= ::Appium::Core.for(self, Caps::IOS_OPS)
            @driver ||= ios_mock_create_session_w3c
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
                                                :toggle_touch_id_enrollment])
          end
        end # class DefinitionTest
      end # module W3C
    end # module Device
  end # module IOS
end # class AppiumLibCoreTest
