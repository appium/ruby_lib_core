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

# rubocop:disable Layout/AlignHash
module Appium
  module Core
    # ref: https://github.com/appium/appium-base-driver/blob/master/lib/mjsonwp/routes.js
    module Commands
      # Some commands differ for each driver.
      COMMAND = {
        # common
        get_all_sessions:           [:get,  'sessions'],
        available_contexts:         [:get,  'session/:session_id/contexts'],
        set_context:                [:post, 'session/:session_id/context'],
        current_context:            [:get,  'session/:session_id/context'],

        touch_actions:              [:post, 'session/:session_id/touch/perform'],
        multi_touch:                [:post, 'session/:session_id/touch/multi/perform'],

        set_immediate_value:        [:post, 'session/:session_id/appium/element/:id/value'],
        replace_value:              [:post, 'session/:session_id/appium/element/:id/replace_value'],

        launch_app:                 [:post, 'session/:session_id/appium/app/launch'],
        close_app:                  [:post, 'session/:session_id/appium/app/close'],
        reset:                      [:post, 'session/:session_id/appium/app/reset'],
        background_app:             [:post, 'session/:session_id/appium/app/background'],
        app_strings:                [:post, 'session/:session_id/appium/app/strings'],

        device_locked?:             [:post, 'session/:session_id/appium/device/is_locked'],
        unlock:                     [:post, 'session/:session_id/appium/device/unlock'],
        lock:                       [:post, 'session/:session_id/appium/device/lock'],
        device_time:                [:get,  'session/:session_id/appium/device/system_time'],
        install_app:                [:post, 'session/:session_id/appium/device/install_app'],
        remove_app:                 [:post, 'session/:session_id/appium/device/remove_app'],
        app_installed?:             [:post, 'session/:session_id/appium/device/app_installed'],
        activate_app:               [:post, 'session/:session_id/appium/device/activate_app'],
        terminate_app:              [:post, 'session/:session_id/appium/device/terminate_app'],
        app_state:                  [:post, 'session/:session_id/appium/device/app_state'],
        shake:                      [:post, 'session/:session_id/appium/device/shake'],
        hide_keyboard:              [:post, 'session/:session_id/appium/device/hide_keyboard'],
        press_keycode:              [:post, 'session/:session_id/appium/device/press_keycode'],
        long_press_keycode:         [:post, 'session/:session_id/appium/device/long_press_keycode'],
        # keyevent is only for Selendroid
        keyevent:                   [:post, 'session/:session_id/appium/device/keyevent'],
        push_file:                  [:post, 'session/:session_id/appium/device/push_file'],
        pull_file:                  [:post, 'session/:session_id/appium/device/pull_file'],
        pull_folder:                [:post, 'session/:session_id/appium/device/pull_folder'],
        get_clipboard:              [:post, 'session/:session_id/appium/device/get_clipboard'],
        set_clipboard:              [:post, 'session/:session_id/appium/device/set_clipboard'],
        finger_print:               [:post, 'session/:session_id/appium/device/finger_print'],
        get_settings:               [:get,  'session/:session_id/appium/settings'],
        update_settings:            [:post, 'session/:session_id/appium/settings'],
        stop_recording_screen:      [:post, 'session/:session_id/appium/stop_recording_screen'],
        start_recording_screen:     [:post, 'session/:session_id/appium/start_recording_screen'],
        compare_images:             [:post, 'session/:session_id/appium/compare_images'],
        is_keyboard_shown:          [:get,  'session/:session_id/appium/device/is_keyboard_shown'],
        execute_driver:             [:post, 'session/:session_id/appium/execute_driver']
      }.freeze

      COMMAND_ANDROID = {
        open_notifications:         [:post, 'session/:session_id/appium/device/open_notifications'],
        toggle_airplane_mode:       [:post, 'session/:session_id/appium/device/toggle_airplane_mode'],
        start_activity:             [:post, 'session/:session_id/appium/device/start_activity'],
        current_activity:           [:get,  'session/:session_id/appium/device/current_activity'],
        current_package:            [:get,  'session/:session_id/appium/device/current_package'],
        get_system_bars:            [:get,  'session/:session_id/appium/device/system_bars'],
        get_display_density:        [:get,  'session/:session_id/appium/device/display_density'],
        toggle_wifi:                [:post, 'session/:session_id/appium/device/toggle_wifi'],
        toggle_data:                [:post, 'session/:session_id/appium/device/toggle_data'],
        toggle_location_services:   [:post, 'session/:session_id/appium/device/toggle_location_services'],
        end_coverage:               [:post, 'session/:session_id/appium/app/end_test_coverage'],
        get_performance_data_types: [:post, 'session/:session_id/appium/performanceData/types'],
        get_performance_data:       [:post, 'session/:session_id/appium/getPerformanceData'],
        get_network_connection:     [:get,  'session/:session_id/network_connection'], # defined also in OSS
        set_network_connection:     [:post, 'session/:session_id/network_connection'], # defined also in OSS

        # only emulator
        send_sms:                   [:post, 'session/:session_id/appium/device/send_sms'],
        gsm_call:                   [:post, 'session/:session_id/appium/device/gsm_call'],
        gsm_signal:                 [:post, 'session/:session_id/appium/device/gsm_signal'],
        gsm_voice:                  [:post, 'session/:session_id/appium/device/gsm_voice'],
        set_network_speed:          [:post, 'session/:session_id/appium/device/network_speed'],
        set_power_capacity:         [:post, 'session/:session_id/appium/device/power_capacity'],
        set_power_ac:               [:post, 'session/:session_id/appium/device/power_ac']
      }.freeze

      COMMAND_IOS = {
        touch_id:                   [:post, 'session/:session_id/appium/simulator/touch_id'],
        toggle_touch_id_enrollment: [:post, 'session/:session_id/appium/simulator/toggle_touch_id_enrollment']
      }.freeze

      COMMANDS = {}.merge(COMMAND).merge(COMMAND_ANDROID).merge(COMMAND_IOS).freeze
    end # module Commands
  end # module Core
end # module Appium
# rubocop:enable Layout/AlignHash
