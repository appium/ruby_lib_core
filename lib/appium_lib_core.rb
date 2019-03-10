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

# Call patch after requiring other files
require_relative 'appium_lib_core/patch'

module Appium
  # convert all keys (including nested) to symbols
  #
  # based on deep_symbolize_keys & deep_transform_keys from rails
  # https://github.com/rails/docrails/blob/a3b1105ada3da64acfa3843b164b14b734456a50/activesupport/lib/active_support/core_ext/hash/keys.rb#L84
  # @param [Hash] hash Hash value to make symbolise
  def self.symbolize_keys(hash)
    raise ArgumentError, 'symbolize_keys requires a hash' unless hash.is_a? Hash

    hash.each_with_object({}) do |pair, acc|
      key = begin
              pair[0].to_sym
            rescue StandardError => e
              ::Appium::Logger.warn(e.message)
              pair[0]
            end

      value = pair[1]
      acc[key] = value.is_a?(Hash) ? symbolize_keys(value) : value
    end
  end

  module Core
    # @see Appium::Core::Driver.for
    def self.for(*args)
      Core::Driver.for(*args)
    end
  end
end
