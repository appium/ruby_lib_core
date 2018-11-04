# rubocop:disable Layout/AlignHash
module Appium
  module Core
    # ref: https://github.com/appium/appium-base-driver/blob/master/lib/mjsonwp/routes.js
    module Commands
      # Some commands differ for each driver.
      COMMAND = {
        # common
        available_contexts:         [:get,  'session/:session_id/contexts'.freeze],
        set_context:                [:post, 'session/:session_id/context'.freeze],
        current_context:            [:get,  'session/:session_id/context'.freeze],

        touch_actions:              [:post, 'session/:session_id/touch/perform'.freeze],
        multi_touch:                [:post, 'session/:session_id/touch/multi/perform'.freeze],

        set_immediate_value:        [:post, 'session/:session_id/appium/element/:id/value'.freeze],
        replace_value:              [:post, 'session/:session_id/appium/element/:id/replace_value'.freeze],

        launch_app:                 [:post, 'session/:session_id/appium/app/launch'.freeze],
        close_app:                  [:post, 'session/:session_id/appium/app/close'.freeze],
        reset:                      [:post, 'session/:session_id/appium/app/reset'.freeze],
        background_app:             [:post, 'session/:session_id/appium/app/background'.freeze],
        app_strings:                [:post, 'session/:session_id/appium/app/strings'.freeze],

        device_locked?:             [:post, 'session/:session_id/appium/device/is_locked'.freeze],
        unlock:                     [:post, 'session/:session_id/appium/device/unlock'.freeze],
        lock:                       [:post, 'session/:session_id/appium/device/lock'.freeze],
        device_time:                [:get,  'session/:session_id/appium/device/system_time'.freeze],
        install_app:                [:post, 'session/:session_id/appium/device/install_app'.freeze],
        remove_app:                 [:post, 'session/:session_id/appium/device/remove_app'.freeze],
        app_installed?:             [:post, 'session/:session_id/appium/device/app_installed'.freeze],
        activate_app:               [:post, 'session/:session_id/appium/device/activate_app'.freeze],
        terminate_app:              [:post, 'session/:session_id/appium/device/terminate_app'.freeze],
        app_state:                  [:post, 'session/:session_id/appium/device/app_state'.freeze],
        shake:                      [:post, 'session/:session_id/appium/device/shake'.freeze],
        hide_keyboard:              [:post, 'session/:session_id/appium/device/hide_keyboard'.freeze],
        press_keycode:              [:post, 'session/:session_id/appium/device/press_keycode'.freeze],
        long_press_keycode:         [:post, 'session/:session_id/appium/device/long_press_keycode'.freeze],
        # keyevent is only for Selendroid
        keyevent:                   [:post, 'session/:session_id/appium/device/keyevent'.freeze],
        push_file:                  [:post, 'session/:session_id/appium/device/push_file'.freeze],
        pull_file:                  [:post, 'session/:session_id/appium/device/pull_file'.freeze],
        pull_folder:                [:post, 'session/:session_id/appium/device/pull_folder'.freeze],
        get_clipboard:              [:post, 'session/:session_id/appium/device/get_clipboard'.freeze],
        set_clipboard:              [:post, 'session/:session_id/appium/device/set_clipboard'.freeze],
        finger_print:               [:post, 'session/:session_id/appium/device/finger_print'.freeze],
        get_settings:               [:get,  'session/:session_id/appium/settings'.freeze],
        update_settings:            [:post, 'session/:session_id/appium/settings'.freeze],
        stop_recording_screen:      [:post, 'session/:session_id/appium/stop_recording_screen'.freeze],
        start_recording_screen:     [:post, 'session/:session_id/appium/start_recording_screen'.freeze],
        compare_images:             [:post, 'session/:session_id/appium/compare_images'.freeze],
        is_keyboard_shown:          [:get,  'session/:session_id/appium/device/is_keyboard_shown'.freeze]
      }.freeze

      COMMAND_ANDROID = {
        open_notifications:         [:post, 'session/:session_id/appium/device/open_notifications'.freeze],
        toggle_airplane_mode:       [:post, 'session/:session_id/appium/device/toggle_airplane_mode'.freeze],
        start_activity:             [:post, 'session/:session_id/appium/device/start_activity'.freeze],
        current_activity:           [:get,  'session/:session_id/appium/device/current_activity'.freeze],
        current_package:            [:get,  'session/:session_id/appium/device/current_package'.freeze],
        get_system_bars:            [:get,  'session/:session_id/appium/device/system_bars'.freeze],
        get_display_density:        [:get,  'session/:session_id/appium/device/display_density'.freeze],
        toggle_wifi:                [:post, 'session/:session_id/appium/device/toggle_wifi'.freeze],
        toggle_data:                [:post, 'session/:session_id/appium/device/toggle_data'.freeze],
        toggle_location_services:   [:post, 'session/:session_id/appium/device/toggle_location_services'.freeze],
        end_coverage:               [:post, 'session/:session_id/appium/app/end_test_coverage'.freeze],
        get_performance_data_types: [:post, 'session/:session_id/appium/performanceData/types'.freeze],
        get_performance_data:       [:post, 'session/:session_id/appium/getPerformanceData'.freeze],
        get_network_connection:     [:get,  'session/:session_id/network_connection'.freeze], # defined also in OSS
        set_network_connection:     [:post, 'session/:session_id/network_connection'.freeze], # defined also in OSS

        # only emulator
        send_sms:                   [:post, 'session/:session_id/appium/device/send_sms'.freeze],
        gsm_call:                   [:post, 'session/:session_id/appium/device/gsm_call'.freeze],
        gsm_signal:                 [:post, 'session/:session_id/appium/device/gsm_signal'.freeze],
        gsm_voice:                  [:post, 'session/:session_id/appium/device/gsm_voice'.freeze],
        set_network_speed:          [:post, 'session/:session_id/appium/device/network_speed'.freeze],
        set_power_capacity:         [:post, 'session/:session_id/appium/device/power_capacity'.freeze],
        set_power_ac:               [:post, 'session/:session_id/appium/device/power_ac'.freeze]
      }.freeze

      COMMAND_IOS = {
        touch_id:                   [:post, 'session/:session_id/appium/simulator/touch_id'.freeze],
        toggle_touch_id_enrollment: [:post, 'session/:session_id/appium/simulator/toggle_touch_id_enrollment'.freeze]
      }.freeze

      COMMANDS = {}.merge(COMMAND).merge(COMMAND_ANDROID).merge(COMMAND_IOS).freeze
    end # module Commands
  end # module Core
end # module Appium
# rubocop:enable Layout/AlignHash
