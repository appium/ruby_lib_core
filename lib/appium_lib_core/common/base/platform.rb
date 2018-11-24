module Appium
  module Core
    class Base
      # Return ::Selenium::WebDriver::Platform module methods
      # Read https://github.com/SeleniumHQ/selenium/blob/master/rb/lib/selenium/webdriver/common/platform.rb
      #
      # @return [::Selenium::WebDriver::Platform]
      #
      # @example
      #
      #   ::Appium::Core::Base.platform.windows? #=> `true` or `false`
      #
      def self.platform
        ::Selenium::WebDriver::Platform
      end
    end
  end
end
