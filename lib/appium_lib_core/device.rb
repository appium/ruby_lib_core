module Appium
  module Core
    module Device
      extend Forwardable

      class << self
        def extended(_mod)
          extend_webdriver_with_forwardable

          # Compatibility for appium_lib. Below command are extended by `extend Appium::Core::Deivce`in appium_lib.
          # TODO: Will remove
          [
            :take_element_screenshot, :save_viewport_screenshot,
            :lock, :device_locked?, :unlock,
            :hide_keyboard, :is_keyboard_shown,
            :ime_activate, :ime_available_engines, :ime_active_engine, :ime_activated, :ime_deactivate,
            :get_settings, :update_settings,
            :within_context, :switch_to_default_context, :current_context, :available_contexts, :set_context,
            :set_immediate_value, :replace_value,
            :push_file, :pull_file, :pull_folder,
            :keyevent, :press_keycode, :long_press_keycode,
            :match_images_features, :find_image_occurrence, :get_images_similarity, :compare_images,
            :launch_app, :close_app, :reset, :app_strings, :background_app,
            :install_app, :remove_app, :app_installed?, :activate_app, :terminate_app,
            :app_state,
            :stop_recording_screen, :stop_and_save_recording_screen,
            :shake, :device_time,
            :touch_actions, :multi_touch
          ].each do |key|
            delegate_from_appium_driver key
          end
        end

        # def extended

        # @private
        # Define method in Bridges
        def add_endpoint_method(method)
          block_given? ? create_bridge_command(method, &Proc.new) : create_bridge_command(method)

          delegate_driver_method method
          delegate_from_appium_driver method
        end

        # @private CoreBridge
        def extend_webdriver_with_forwardable
          return if ::Appium::Core::Base::Driver.is_a? Forwardable

          ::Appium::Core::Base::Driver.class_eval do
            extend Forwardable
          end
        end

        private

        def delegate_from_appium_driver(method, delegation_target = :driver)
          def_delegator delegation_target, method
        end

        def delegate_driver_method(method)
          return if ::Appium::Core::Base::Driver.method_defined? method

          ::Appium::Core::Base::Driver.class_eval { def_delegator :@bridge, method }
        end

        def create_bridge_command(method)
          ::Appium::Core::Base::Bridge::MJSONWP.class_eval do
            block_given? ? class_eval(&Proc.new) : define_method(method) { execute method }
          end
          ::Appium::Core::Base::Bridge::W3C.class_eval do
            block_given? ? class_eval(&Proc.new) : define_method(method) { execute method }
          end
        end
      end # class << self
    end
  end # module Core
end # module Appium
