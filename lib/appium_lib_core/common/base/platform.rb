module Appium
  module Core
    class Base
      # Return ::Selenium::WebDriver::Platform module methods
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
