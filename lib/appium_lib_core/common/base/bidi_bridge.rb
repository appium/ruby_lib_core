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

require_relative 'bridge'

module Appium
  module Core
    class Base
      class BiDiBridge < ::Appium::Core::Base::Bridge
        attr_reader :bidi

        # Override
        # Creates session handling.
        #
        # @param [::Appium::Core::Base::Capabilities, Hash] capabilities A capability
        # @return [::Appium::Core::Base::Capabilities]
        #
        # @example
        #
        #   opts = {
        #     caps: {
        #       platformName: :android,
        #       automationName: 'uiautomator2',
        #       platformVersion: '15',
        #       deviceName: 'Android',
        #.      webSocketUrl: true,
        #     },
        #     appium_lib: {
        #       wait: 30
        #     }
        #   }
        #   core = ::Appium::Core.for(caps)
        #   driver = core.start_driver
        #
        def create_session(capabilities)
          super
          socket_url = @capabilities[:web_socket_url]
          @bidi = ::Selenium::WebDriver::BiDi.new(url: socket_url)
        end

        def get(url)
          browsing_context.navigate(url)
        end

        def go_back
          browsing_context.traverse_history(-1)
        end

        def go_forward
          browsing_context.traverse_history(1)
        end

        def refresh
          browsing_context.reload
        end

        def quit
          super
        ensure
          bidi.close
        end

        def close
          execute(:close_window).tap { |handles| bidi.close if handles.empty? }
        end

        private

        def browsing_context
          @browsing_context ||= ::Selenium::WebDriver::BiDi::BrowsingContext.new(self)
        end
      end # class BiDiBridge
    end # class Base
  end # module Core
end # module Appium
