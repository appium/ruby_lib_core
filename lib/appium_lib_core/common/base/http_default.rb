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

          # Update `server_url` to.
          # Set `@http` as nil to re-create http client for the server_url
          # @private
          #
          # @param [string] scheme: A scheme to update server_url to
          # @param [string] host: A host to update server_url to
          # @param [string|integer] port: A port number to update server_url to
          # @param [string] path: A path to update server_url to
          #
          # @return [URI] An instance of URI updated to. Returns default `server_url` if some of arguments are `nil`
          def update_sending_request_to(scheme:, host:, port:, path:)
            return @server_url unless validate_url_param(scheme, host, port, path)

            Logger.debug("[experimental] This feature, #{__method__}, is an experimental")

            # Add / if `path` does not have it
            path = path.start_with?('/') ? path : "/#{path}"
            path = path.end_with?('/') ? path : "#{path}/"

            @http = nil
            @server_url = URI.parse "#{scheme}://#{host}:#{port}#{path}"
          end

          private

          def validate_url_param(scheme, host, port, path)
            !(scheme.nil? || host.nil? || port.nil? || path.nil?)
          end

          public

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
