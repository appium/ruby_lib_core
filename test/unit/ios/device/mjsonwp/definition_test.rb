require 'test_helper'
require 'webmock/minitest'

# $ rake test:unit TEST=test/unit/ios/device/mjsonwp/definition_test.rb
class AppiumLibCoreTest
  module IOS
    module Device
      module MJSONWP
        class DefinitionTest < Minitest::Test
          include AppiumLibCoreTest::Mock

          def setup
            @core ||= ::Appium::Core.for(self, Caps.ios)
            @driver ||= ios_mock_create_session
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
                                                :is_keyboard_shown,
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
      end # module MJSONWP
    end # module Device
  end # module IOS
end # class AppiumLibCoreTest
