require_relative 'base/command'

module Appium
  module Core
    # ref: https://github.com/appium/appium-base-driver/blob/master/lib/mjsonwp/routes.js
    module Commands
      COMMAND_NO_ARG = {
        # Common
        shake:                      [:post, 'session/:session_id/appium/device/shake'.freeze],
        launch_app:                 [:post, 'session/:session_id/appium/app/launch'.freeze],
        close_app:                  [:post, 'session/:session_id/appium/app/close'.freeze],
        reset:                      [:post, 'session/:session_id/appium/app/reset'.freeze],
        device_locked?:             [:post, 'session/:session_id/appium/device/is_locked'.freeze],
        unlock:                     [:post, 'session/:session_id/appium/device/unlock'.freeze],
        device_time:                [:get,  'session/:session_id/appium/device/system_time'.freeze],
        current_context:            [:get,  'session/:session_id/context'.freeze],

        # Android
        open_notifications:         [:post, 'session/:session_id/appium/device/open_notifications'.freeze],
        toggle_airplane_mode:       [:post, 'session/:session_id/appium/device/toggle_airplane_mode'.freeze],
        current_activity:           [:get,  'session/:session_id/appium/device/current_activity'.freeze],
        current_package:            [:get,  'session/:session_id/appium/device/current_package'.freeze],
        get_system_bars:            [:get,  'session/:session_id/appium/device/system_bars'.freeze],
        get_display_density:        [:get,  'session/:session_id/appium/device/display_density'.freeze],
        is_keyboard_shown:          [:get,  'session/:session_id/appium/device/is_keyboard_shown'.freeze],
        get_network_connection:     [:get,  'session/:session_id/network_connection'.freeze], # defined also in OSS
        get_performance_data_types: [:post, 'session/:session_id/appium/performanceData/types'.freeze]
        # iOS
      }.freeze

      # Some commands differ for each driver.
      COMMAND = {
        # common
        available_contexts:         [:get,  'session/:session_id/contexts'.freeze],
        set_context:                [:post, 'session/:session_id/context'.freeze],
        app_strings:                [:post, 'session/:session_id/appium/app/strings'.freeze],
        lock:                       [:post, 'session/:session_id/appium/device/lock'.freeze],
        install_app:                [:post, 'session/:session_id/appium/device/install_app'.freeze],
        remove_app:                 [:post, 'session/:session_id/appium/device/remove_app'.freeze],
        app_installed?:             [:post, 'session/:session_id/appium/device/app_installed'.freeze],
        activate_app:               [:post, 'session/:session_id/appium/device/activate_app'.freeze],
        terminate_app:              [:post, 'session/:session_id/appium/device/terminate_app'.freeze],
        background_app:             [:post, 'session/:session_id/appium/app/background'.freeze],
        hide_keyboard:              [:post, 'session/:session_id/appium/device/hide_keyboard'.freeze],
        press_keycode:              [:post, 'session/:session_id/appium/device/press_keycode'.freeze],
        long_press_keycode:         [:post, 'session/:session_id/appium/device/long_press_keycode'.freeze],
        # keyevent is only for Selendroid
        keyevent:                   [:post, 'session/:session_id/appium/device/keyevent'.freeze],
        set_immediate_value:        [:post, 'session/:session_id/appium/element/:id/value'.freeze],
        replace_value:              [:post, 'session/:session_id/appium/element/:id/replace_value'.freeze],
        push_file:                  [:post, 'session/:session_id/appium/device/push_file'.freeze],
        pull_file:                  [:post, 'session/:session_id/appium/device/pull_file'.freeze],
        pull_folder:                [:post, 'session/:session_id/appium/device/pull_folder'.freeze],
        get_settings:               [:get,  'session/:session_id/appium/settings'.freeze],
        update_settings:            [:post, 'session/:session_id/appium/settings'.freeze],
        touch_actions:              [:post, 'session/:session_id/touch/perform'.freeze],
        multi_touch:                [:post, 'session/:session_id/touch/multi/perform'.freeze],
        stop_recording_screen:      [:post, 'session/:session_id/appium/stop_recording_screen'.freeze],
        start_recording_screen:     [:post, 'session/:session_id/appium/start_recording_screen'.freeze]
      }.freeze

      COMMAND_ANDROID = {
        start_activity:             [:post, 'session/:session_id/appium/device/start_activity'.freeze],
        end_coverage:               [:post, 'session/:session_id/appium/app/end_test_coverage'.freeze],
        set_network_connection:     [:post, 'session/:session_id/network_connection'.freeze], # defined also in OSS
        get_performance_data:       [:post, 'session/:session_id/appium/getPerformanceData'.freeze]
      }.freeze

      COMMAND_IOS = {
        touch_id:                   [:post, 'session/:session_id/appium/simulator/touch_id'.freeze],
        toggle_touch_id_enrollment: [:post, 'session/:session_id/appium/simulator/toggle_touch_id_enrollment'.freeze]
      }.freeze

      COMMANDS = {}.merge(COMMAND).merge(COMMAND_ANDROID).merge(COMMAND_IOS)
                   .merge(COMMAND_NO_ARG).freeze

      COMMANDS_EXTEND_MJSONWP = COMMANDS.merge(::Appium::Core::Base::Commands::OSS).merge(
        {
          # W3C already has.
          take_element_screenshot:    [:get, 'session/:session_id/element/:id/screenshot'.freeze]
        }
      ).freeze
      COMMANDS_EXTEND_W3C = COMMANDS.merge(::Appium::Core::Base::Commands::W3C).merge(
        {
          # ::Appium::Core::Base::Commands::OSS has the following commands and Appium also use them.
          # Delegated to ::Appium::Core::Base::Commands::OSS commands
          status:                    [:get, 'status'.freeze],
          is_element_displayed:      [:get, 'session/:session_id/element/:id/displayed'.freeze],

          # FIXME: remove after apply https://github.com/SeleniumHQ/selenium/pull/5249
          # The fix will be included in selenium-3.8.2
          get_page_source: [:get, 'session/:session_id/source'.freeze],

          get_timeouts: [:get, 'session/:session_id/timeouts'.freeze],

          ## Add OSS commands to W3C commands
          ### rotatable
          get_screen_orientation: [:get, 'session/:session_id/orientation'.freeze],
          set_screen_orientation: [:post, 'session/:session_id/orientation'.freeze],

          get_location: [:get, 'session/:session_id/location'.freeze],
          set_location: [:post, 'session/:session_id/location'.freeze],

          ### For IME
          ime_get_available_engines: [:get,  'session/:session_id/ime/available_engines'.freeze],
          ime_get_active_engine:     [:get,  'session/:session_id/ime/active_engine'.freeze],
          ime_is_activated:          [:get,  'session/:session_id/ime/activated'.freeze],
          ime_deactivate:            [:post, 'session/:session_id/ime/deactivate'.freeze],
          ime_activate_engine:       [:post, 'session/:session_id/ime/activate'.freeze],

          ### Logs
          get_available_log_types: [:get, 'session/:session_id/log/types'.freeze],
          get_log: [:post, 'session/:session_id/log'.freeze]
        }
      ).freeze
    end
  end
end
