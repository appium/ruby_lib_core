require_relative '../../version'

module Appium
  module Core
    class Base
      module Http
        class Default < Selenium::WebDriver::Remote::Http::Default
          DEFAULT_HEADERS = { 'Accept' => CONTENT_TYPE, 'User-Agent' => "appium/ruby_lib_core/#{VERSION}" }.freeze
        end
      end
    end
  end
end
