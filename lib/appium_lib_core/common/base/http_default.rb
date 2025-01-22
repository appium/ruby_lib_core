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

require 'securerandom'
# to avoid mysterious resolution error 'uninitialized constant Selenium::WebDriver::Remote::Http::Default::Net (NameError)'
require 'net/http'

require_relative '../../version'

module Appium
  module Core
    class Base
      module Http
        module RequestHeaders
          KEYS = {
            idempotency: 'X-Idempotency-Key'
          }.freeze
        end

        class Default < ::Selenium::WebDriver::Remote::Http::Default
          attr_reader :additional_headers

          ::Selenium::WebDriver::Remote::Http::Common.user_agent =
            "appium/ruby_lib_core/#{VERSION} (#{::Selenium::WebDriver::Remote::Http::Common.user_agent})"

          # override
          def initialize(open_timeout: nil, read_timeout: nil)
            @open_timeout = open_timeout
            @read_timeout = read_timeout
            @additional_headers = {}
            super
          end

          def set_additional_header(key, value)
            @additional_headers[key] = value
            ::Selenium::WebDriver::Remote::Http::Common.extra_headers = @additional_headers
          end

          def delete_additional_header(key)
            @additional_headers.delete key
            ::Selenium::WebDriver::Remote::Http::Common.extra_headers = @additional_headers
            @common_headers.delete key if defined? @common_headers
          end

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

            # Add / if 'path' does not have it
            path = "/#{path}" unless path.start_with?('/')
            path = "#{path}/" unless path.end_with?('/')

            @http = nil
            @server_url = URI.parse "#{scheme}://#{host}:#{port}#{path}"
          end

          private

          def validate_url_param(scheme, host, port, path)
            return true unless [scheme, host, port, path].include?(nil)

            message = "Given parameters are scheme: '#{scheme}', host: '#{host}', port: '#{port}', path: '#{path}'"
            ::Appium::Logger.debug(message)
            false
          end
        end
      end
    end
  end
end
