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
    class Base
      class Options < ::Selenium::WebDriver::Options
        APPIUM_PREFIX = 'appium:'

        class << self
          def set_capabilities(opts)
            (::Selenium::WebDriver::Options::W3C_OPTIONS + opts.keys).each do |key|
              next if method_defined? key

              define_method key do
                @options[key]
              end

              define_method "#{key}=" do |value|
                @options[key] = value
              end
            end
          end
        end

        # def add_appium_prefix
        #   @options.each do |name, value|
        #     next if value.nil?
        #     next if value.is_a?(String) && value.empty?

        #     capability_name = name.to_s
        #     w3c_name = extension_prefix?(capability_name) ? name : "#{APPIUM_PREFIX}#{capability_name}"

        #     w3c_capabilities[w3c_name] = value
        #   end
        # end

        attr_accessor :options

        def initialize(opts)
          @options = opts
          self.class.set_capabilities opts
        end

        def as_json(*)
          appium_options = @options.dup
          w3c_options = process_w3c_options(options)

          @options.each do |name, value|
            next if value.nil?
            next if value.is_a?(String) && value.empty?

            _value = appium_options.delete(name)

            capability_name = name.to_s
            w3c_name = extension_prefix?(capability_name) ? name : "#{APPIUM_PREFIX}#{capability_name}"
            appium_options[w3c_name] = value
          end
          generate_as_json(w3c_options.merge(appium_options))
        end

        def camel_case(str)
          str.gsub(/_([a-z])/) { Regexp.last_match(1).upcase }
        end

        def extension_prefix?(capability_name)
          snake_cased_capability_names = W3C_OPTIONS.map(&:to_s)
          camel_cased_capability_names = snake_cased_capability_names.map { |v| camel_case(v) }

          # Check 'EXTENSION_CAPABILITY_PATTERN'
          snake_cased_capability_names.include?(capability_name) ||
            camel_cased_capability_names.include?(capability_name) ||
            capability_name.match(':')
        end
      end

      module Capabilities
        # @private
        # @param [Hash] opts_caps Capabilities for Appium server. All capability keys are converted to lowerCamelCase when
        #                         this client sends capabilities to Appium server as JSON format.
        # @return [::Selenium::WebDriver::Remote::Capabilities] Return instance of Appium::Core::Base::Capabilities
        #                         inherited ::Selenium::WebDriver::Remote::Capabilities
        def self.create_capabilities(opts_caps = {})
          # TODO: Move to 'Options' way instead of 'Capabilities'.
          # Selenium 5 will have Options instead of 'Capabilities'.
          # https://github.com/SeleniumHQ/selenium/blob/trunk/rb/lib/selenium/webdriver/common/options.rb
          # Then, Ruby client also shoud move to the Options way.
          # Appium's capabilities could change by depending on Appium versions. So it does not have
          # standard options like chrome and firefox etc. So, the implementation should differ from
          # other browsers. But here should inherit `Options` to follow Selenium.
          ::Appium::Core::Base::Options.new(opts_caps)
        end
      end
    end
  end
end
