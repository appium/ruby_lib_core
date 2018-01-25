require 'selenium-webdriver'

require_relative 'appium_lib_core/version'
require_relative 'appium_lib_core/common'
require_relative 'appium_lib_core/patch'
require_relative 'appium_lib_core/driver'

# for multi touch related methods
require_relative 'appium_lib_core/device/touch_actions'
require_relative 'appium_lib_core/device/multi_touch'
require_relative 'appium_lib_core/device/screen_record'

require_relative 'appium_lib_core/android'
require_relative 'appium_lib_core/android_uiautomator2'
require_relative 'appium_lib_core/android_espresso'

require_relative 'appium_lib_core/ios'
require_relative 'appium_lib_core/ios_xcuitest'

module Appium
  # convert all keys (including nested) to symbols
  #
  # based on deep_symbolize_keys & deep_transform_keys from rails
  # https://github.com/rails/docrails/blob/a3b1105ada3da64acfa3843b164b14b734456a50/activesupport/lib/active_support/core_ext/hash/keys.rb#L84
  # @param [Hash] hash Hash value to make symbolise
  def self.symbolize_keys(hash)
    raise 'symbolize_keys requires a hash' unless hash.is_a? Hash
    result = {}
    hash.each do |key, value|
      key = key.to_sym rescue key # rubocop:disable Style/RescueModifier
      result[key] = value.is_a?(Hash) ? symbolize_keys(value) : value
    end
    result
  end

  module Core
    # @see Appium::Core::Driver.for
    def self.for(*args)
      Core::Driver.for(*args)
    end
  end
end
