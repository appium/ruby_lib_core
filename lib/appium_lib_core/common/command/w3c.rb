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
    module Commands
      module W3C
        COMMANDS = ::Appium::Core::Commands::COMMANDS.merge(::Appium::Core::Base::Commands::W3C).merge(
          {
            # ::Appium::Core::Base::Commands::OSS has the following commands and Appium also use them.
            # Delegated to ::Appium::Core::Base::Commands::OSS commands
            status:                    [:get, 'status'], # https://w3c.github.io/webdriver/#dfn-status
            is_element_displayed:      [:get, 'session/:session_id/element/:id/displayed'], # hint: https://w3c.github.io/webdriver/#element-displayedness

            get_timeouts:              [:get, 'session/:session_id/timeouts'], # https://w3c.github.io/webdriver/#get-timeouts

            # Add OSS commands to W3C commands. We can remove them if we would like to remove them from W3C module.
            ### Session capability
            get_capabilities:          [:get, 'session/:session_id'],

            ### rotatable
            get_screen_orientation:    [:get, 'session/:session_id/orientation'],
            set_screen_orientation:    [:post, 'session/:session_id/orientation'],

            get_location:              [:get, 'session/:session_id/location'],
            set_location:              [:post, 'session/:session_id/location'],

            ### For IME
            ime_get_available_engines: [:get,  'session/:session_id/ime/available_engines'],
            ime_get_active_engine:     [:get,  'session/:session_id/ime/active_engine'],
            ime_is_activated:          [:get,  'session/:session_id/ime/activated'],
            ime_deactivate:            [:post, 'session/:session_id/ime/deactivate'],
            ime_activate_engine:       [:post, 'session/:session_id/ime/activate'],

            send_keys_to_active_element: [:post, 'session/:session_id/keys'],

            ### Logs
            get_available_log_types:   [:get, 'session/:session_id/log/types'],
            get_log:                   [:post, 'session/:session_id/log']
          }
        ).freeze
      end # module W3C
    end # module Commands
  end # module Core
end # module Appium
# rubocop:enable Layout/AlignHash
