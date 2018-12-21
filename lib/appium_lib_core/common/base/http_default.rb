require_relative '../../version'

module Appium
  module Core
    class Base
      module Http
        class Default < Selenium::WebDriver::Remote::Http::Default
          DEFAULT_HEADERS = {
            'Accept' => CONTENT_TYPE,
            'Content-Type' => "#{CONTENT_TYPE}; charset=UTF-8",
            'User-Agent' =>
              "appium/ruby_lib_core/#{VERSION} (#{::Selenium::WebDriver::Remote::Http::Common::DEFAULT_HEADERS['User-Agent']})"
          }.freeze

          # override to use default header
          # https://github.com/SeleniumHQ/selenium/blob/master/rb/lib/selenium/webdriver/remote/http/common.rb#L46
          def call(verb, url, command_hash)
            url      = server_url.merge(url) unless url.is_a?(URI)
            headers  = DEFAULT_HEADERS.dup
            headers['Cache-Control'] = 'no-cache' if verb == :get

            if command_hash
              payload                   = JSON.generate(command_hash)
              headers['Content-Length'] = payload.bytesize.to_s if [:post, :put].include?(verb)

              Logger.info("   >>> #{url} | #{payload}")
              Logger.debug("     > #{headers.inspect}")
            elsif verb == :post
              payload = '{}'
              headers['Content-Length'] = '2'
            end

            request verb, url, headers, payload
          end
        end
      end
    end
  end
end
