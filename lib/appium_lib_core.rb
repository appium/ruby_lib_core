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

require 'selenium-webdriver'

require_relative 'appium_lib_core/version'
require_relative 'appium_lib_core/common'
require_relative 'appium_lib_core/driver'
require_relative 'appium_lib_core/device'
require_relative 'appium_lib_core/element'
require_relative 'appium_lib_core/support/event_firing_bridge'

module Appium
  # convert the top level keys to symbols.
  #
  # @param [Hash] hash Hash value to make symbolise
  #
  # @example
  #
  #   opts = Appium.symbolize_keys(opts)
  #
  def self.symbolize_keys(hash, nested: false, enable_deprecation_msg: true)
    # FIXME: As https://github.com/appium/ruby_lib/issues/945, we must remove this implicit string to symbol.
    # But appium_lib_core's some capability handling expect to be symbol, so we should test to remove
    # the methods which expect the symbol first.
    raise ::Appium::Core::Error::ArgumentError, 'symbolize_keys requires a hash' unless hash.is_a? Hash

    hash.each_with_object({}) do |pair, acc|
      key = begin
        if enable_deprecation_msg && !(pair[0].is_a? Symbol)
          ::Appium::Logger.warn("[Deprecation] The key '#{pair[0]}' must be a symbol while currently it " \
                                "is #{pair[0].class.name}. Please define the key as a Symbol. " \
                                'Converting it to Symbol for now.')
        end

        pair[0].to_sym
      rescue StandardError => e
        ::Appium::Logger.warn(e.message)
        pair[0]
      end

      value = pair[1]
      acc[key] = if nested
                   value.is_a?(Hash) ? symbolize_keys(value, nested: false, enable_deprecation_msg: false) : value
                 else
                   value
                 end
    end
  end

  module Core
    # @see Appium::Core::Driver.for
    def self.for(opts = {})
      Core::Driver.for(opts)
    end
  end
end
