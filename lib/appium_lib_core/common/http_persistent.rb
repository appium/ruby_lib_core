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

require 'net/http/persistent'

module Appium
  module Core
    class Base
      module Http
        # api private
        class Persistent < ::Appium::Core::Base::Http::Default
          def close
            @http.shutdown if @http # rubocop:disable Style/SafeNavigation
          end

          private

          def start
            # no need to explicitly start connection
          end

          def new_http_client
            proxy = nil

            if @proxy
              unless @proxy.respond_to?(:http)
                url = @proxy.http
                raise Error::WebDriverError, "expected HTTP proxy, got #{@proxy.inspect}" unless url
              end
              proxy = URI.parse(url)
            end

            Net::HTTP::Persistent.new name: 'webdriver', proxy: proxy
          end

          def response_for(request)
            http.request server_url, request
          end
        end
      end
    end
  end
end
