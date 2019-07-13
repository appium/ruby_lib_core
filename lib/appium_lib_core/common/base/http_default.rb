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

          # Update <code>server_url</code> provided when ruby_lib _core created a default http client.
          # Set <code>@http</code> as nil to re-create http client for the <code>server_url</code>
          #
          # @param [string] scheme A scheme to update server_url to
          # @param [string] host A host to update server_url to
          # @param [string|integer] port A port number to update server_url to
          # @param [string] path A path to update server_url to
          #
          # @return [URI] An instance of URI updated to. Returns default +server_url+ if some of arguments are +nil+
          def update_sending_request_to(scheme:, host:, port:, path:)
            return @server_url unless validate_url_param(scheme, host, port, path)

            ::Appium::Logger.debug("[experimental] This feature, #{__method__}, is an experimental")

            # Add / if 'path' does not have it
            path = path.start_with?('/') ? path : "/#{path}"
            path = path.end_with?('/') ? path : "#{path}/"

            @http = nil
            @server_url = URI.parse "#{scheme}://#{host}:#{port}#{path}"
          end

          private

          def validate_url_param(scheme, host, port, path)
            return true unless [scheme, host, port, path].include?(nil)

            message = "Given parameters are scheme: '#{scheme}', host: '#{host}', port: '#{port}', path: '#{path}'"
            ::Appium::Logger.warn(message)
            false
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

              ::Appium::Logger.info("   >>> #{url} | #{payload}")
              ::Appium::Logger.debug("     > #{headers.inspect}")
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
