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

module Appium
  # @private
  #
  # convert the top level keys to symbols
  #
  # @param [Hash] hash Hash value to make symbolise
  def self.symbolize_keys(hash)
    raise ::Appium::Core::Error::ArgumentError, 'symbolize_keys requires a hash' unless hash.is_a? Hash

    hash.each_with_object({}) do |pair, acc|
      key = begin
        unless pair[0].is_a? Symbol
          ::Appium::Logger.warn("[Deprecation] The key '#{pair[0]}' must be a symbol while currently it " \
                                "is #{pair[0].class.name}. Please define the key as a Symbol. " \
                                'Converting it to Symbol for now.')
        end

        pair[0].to_sym
      rescue StandardError => e
        ::Appium::Logger.warn(e.message)
        pair[0]
      end
      acc[key] = pair[1]
    end
  end

  module Core
    # @see Appium::Core::Driver.for
    def self.for(*args)
      Core::Driver.for(*args)
    end
  end
end
