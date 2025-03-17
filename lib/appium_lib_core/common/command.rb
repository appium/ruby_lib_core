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

module Appium
  module Core
    # ref: https://github.com/appium/appium-base-driver/blob/master/lib/mjsonwp/routes.js
    module Commands
      # Some commands differ for each driver.
      COMMAND = {
        ###
        # W3C
        ###
        status: [:get, 'status'],

        #
        # session handling
        #

        new_session: [:post, 'session'],
        delete_session: [:delete, 'session/:session_id'],

        #
        # basic driver
        #

        get: [:post, 'session/:session_id/url'],
        get_current_url: [:get, 'session/:session_id/url'],
        back: [:post, 'session/:session_id/back'],
        forward: [:post, 'session/:session_id/forward'],
        refresh: [:post, 'session/:session_id/refresh'],
        get_title: [:get, 'session/:session_id/title'],

        #
        # window and Frame handling
        #

        get_window_handle: [:get, 'session/:session_id/window'],
        new_window: [:post, 'session/:session_id/window/new'],
        close_window: [:delete, 'session/:session_id/window'],
        switch_to_window: [:post, 'session/:session_id/window'],
        get_window_handles: [:get, 'session/:session_id/window/handles'],
        fullscreen_window: [:post, 'session/:session_id/window/fullscreen'],
        minimize_window: [:post, 'session/:session_id/window/minimize'],
        maximize_window: [:post, 'session/:session_id/window/maximize'],
        set_window_size: [:post, 'session/:session_id/window/size'],
        get_window_size: [:get, 'session/:session_id/window/size'],
        set_window_position: [:post, 'session/:session_id/window/position'],
        get_window_position: [:get, 'session/:session_id/window/position'],
        set_window_rect: [:post, 'session/:session_id/window/rect'],
        get_window_rect: [:get, 'session/:session_id/window/rect'],
        switch_to_frame: [:post, 'session/:session_id/frame'],
        switch_to_parent_frame: [:post, 'session/:session_id/frame/parent'],

        #
        # element
        #

        find_element: [:post, 'session/:session_id/element'],
        find_elements: [:post, 'session/:session_id/elements'],
        find_child_element: [:post, 'session/:session_id/element/:id/element'],
        find_child_elements: [:post, 'session/:session_id/element/:id/elements'],
        find_shadow_child_element: [:post, 'session/:session_id/shadow/:id/element'],
        find_shadow_child_elements: [:post, 'session/:session_id/shadow/:id/elements'],
        get_active_element: [:get, 'session/:session_id/element/active'],
        is_element_selected: [:get, 'session/:session_id/element/:id/selected'],
        get_element_attribute: [:get, 'session/:session_id/element/:id/attribute/:name'],
        get_element_property: [:get, 'session/:session_id/element/:id/property/:name'],
        get_element_css_value: [:get, 'session/:session_id/element/:id/css/:property_name'],
        get_element_aria_role: [:get, 'session/:session_id/element/:id/computedrole'],
        get_element_aria_label: [:get, 'session/:session_id/element/:id/computedlabel'],
        get_element_text: [:get, 'session/:session_id/element/:id/text'],
        get_element_tag_name: [:get, 'session/:session_id/element/:id/name'],
        get_element_rect: [:get, 'session/:session_id/element/:id/rect'],
        is_element_enabled: [:get, 'session/:session_id/element/:id/enabled'],

        #
        # document handling
        #

        get_page_source: [:get, 'session/:session_id/source'],
        execute_script: [:post, 'session/:session_id/execute/sync'],
        execute_async_script: [:post, 'session/:session_id/execute/async'],

        #
        # cookies
        #

        get_all_cookies: [:get, 'session/:session_id/cookie'],
        get_cookie: [:get, 'session/:session_id/cookie/:name'],
        add_cookie: [:post, 'session/:session_id/cookie'],
        delete_cookie: [:delete, 'session/:session_id/cookie/:name'],
        delete_all_cookies: [:delete, 'session/:session_id/cookie'],

        #
        # timeouts
        #

        set_timeout: [:post, 'session/:session_id/timeouts'],

        #
        # actions
        #

        actions: [:post, 'session/:session_id/actions'],
        release_actions: [:delete, 'session/:session_id/actions'],
        print_page: [:post, 'session/:session_id/print'],

        #
        # Element Operations
        #

        element_click: [:post, 'session/:session_id/element/:id/click'],
        element_tap: [:post, 'session/:session_id/element/:id/tap'],
        element_clear: [:post, 'session/:session_id/element/:id/clear'],
        element_send_keys: [:post, 'session/:session_id/element/:id/value'],

        #
        # alerts
        #

        dismiss_alert: [:post, 'session/:session_id/alert/dismiss'],
        accept_alert: [:post, 'session/:session_id/alert/accept'],
        get_alert_text: [:get, 'session/:session_id/alert/text'],
        send_alert_text: [:post, 'session/:session_id/alert/text'],

        #
        # screenshot
        #

        take_screenshot: [:get, 'session/:session_id/screenshot'],
        take_element_screenshot: [:get, 'session/:session_id/element/:id/screenshot'],

        #
        # server extensions
        #

        upload_file: [:post, 'session/:session_id/se/file'],

        ###
        # Used by Appium, but no in W3C
        ###

        # ::Appium::Core::Base::Commands::OSS has the following commands and Appium also use them.
        # Delegated to ::Appium::Core::Base::Commands::OSS commands
        is_element_displayed: [:get, 'session/:session_id/element/:id/displayed'], # hint: https://w3c.github.io/webdriver/#element-displayedness

        get_timeouts: [:get, 'session/:session_id/timeouts'], # https://w3c.github.io/webdriver/#get-timeouts

        ### rotatable
        get_screen_orientation: [:get, 'session/:session_id/orientation'],
        set_screen_orientation: [:post, 'session/:session_id/orientation'],

        get_location: [:get, 'session/:session_id/location'],
        set_location: [:post, 'session/:session_id/location'],

        ### For IME
        ime_get_available_engines: [:get, 'session/:session_id/ime/available_engines'],
        ime_get_active_engine: [:get, 'session/:session_id/ime/active_engine'],
        ime_is_activated: [:get, 'session/:session_id/ime/activated'],
        ime_deactivate: [:post, 'session/:session_id/ime/deactivate'],
        ime_activate_engine: [:post, 'session/:session_id/ime/activate'],

        ### Logs based on w3c selenium clients
        get_available_log_types: [:get, 'session/:session_id/se/log/types'],
        get_log: [:post, 'session/:session_id/se/log'],

        ###
        # Appium own
        ###

        # common
        available_contexts: [:get, 'session/:session_id/contexts'],
        set_context: [:post, 'session/:session_id/context'],
        current_context: [:get, 'session/:session_id/context'],

        device_time: [:get, 'session/:session_id/appium/device/system_time'],
        install_app: [:post, 'session/:session_id/appium/device/install_app'],
        remove_app: [:post, 'session/:session_id/appium/device/remove_app'],
        app_installed?: [:post, 'session/:session_id/appium/device/app_installed'],
        activate_app: [:post, 'session/:session_id/appium/device/activate_app'],
        terminate_app: [:post, 'session/:session_id/appium/device/terminate_app'],
        push_file: [:post, 'session/:session_id/appium/device/push_file'],
        pull_file: [:post, 'session/:session_id/appium/device/pull_file'],
        pull_folder: [:post, 'session/:session_id/appium/device/pull_folder'],
        get_settings: [:get, 'session/:session_id/appium/settings'],
        update_settings: [:post, 'session/:session_id/appium/settings'],
        stop_recording_screen: [:post, 'session/:session_id/appium/stop_recording_screen'],
        start_recording_screen: [:post, 'session/:session_id/appium/start_recording_screen'],
        compare_images: [:post, 'session/:session_id/appium/compare_images'],
        execute_driver: [:post, 'session/:session_id/appium/execute_driver'],
        post_log_event: [:post, 'session/:session_id/appium/log_event'],
        get_log_events: [:post, 'session/:session_id/appium/events']
      }.freeze

      COMMAND_ANDROID = {
        # For chromium: https://chromium.googlesource.com/chromium/src/+/master/chrome/test/chromedriver/server/http_handler.cc
        chrome_send_command: [:post, 'session/:session_id/goog/cdp/execute']
      }.freeze

      COMMANDS = {}.merge(COMMAND).merge(COMMAND_ANDROID).freeze
    end # module Commands
  end # module Core
end # module Appium
