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
  module Support
    class EventFiringBridge < ::Selenium::WebDriver::Support::EventFiringBridge
      # This module inherits ::Selenium::WebDriver::Support::EventFiringBridge
      # to provide customer listener availability.
      # https://github.com/SeleniumHQ/selenium/blob/trunk/rb/lib/selenium/webdriver/support/event_firing_bridge.rb#L79

      def initialize(delegate, listener, **opts)
        @appium_options = opts
        super(delegate, listener)
      end

      def find_element_by(how, what, parent = nil)
        e = dispatch(:find, how, what, driver) do
          @delegate.find_element_by how, what, parent
        end

        ::Appium::Core::Element.new self, e.ref.last
      end

      def find_elements_by(how, what, parent = nil)
        es = dispatch(:find, how, what, driver) do
          @delegate.find_elements_by(how, what, parent)
        end

        es.map { |e| ::Appium::Core::Element.new self, e.ref.last }
      end

      private

      def create_element(ref)
        ::Appium::Core::Element.new @delegate, ref
      end

      def driver
        # To not gives the listener
        @appium_options.delete(:listener)

        @driver ||= ::Appium::Core::Base::Driver.new(bridge: self, listener: nil, **@appium_options)
      end
    end
  end
end
