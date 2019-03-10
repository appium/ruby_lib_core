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

require 'base64'

module Appium
  module Core
    module Android
      module Device
        module Clipboard
          def self.add_methods
            ::Appium::Core::Device.add_endpoint_method(:get_clipboard) do
              def get_clipboard(content_type: :plaintext)
                unless ::Appium::Core::Base::Device::Clipboard::CONTENT_TYPE.member?(content_type)
                  raise "content_type should be #{::Appium::Core::Base::Device::Clipboard::CONTENT_TYPE}"
                end

                params = { contentType: content_type }

                data = execute(:get_clipboard, {}, params)
                Base64.decode64 data
              end
            end

            ::Appium::Core::Device.add_endpoint_method(:set_clipboard) do
              def set_clipboard(content:, content_type: :plaintext, label: nil)
                unless ::Appium::Core::Base::Device::Clipboard::CONTENT_TYPE.member?(content_type)
                  raise "content_type should be #{::Appium::Core::Base::Device::Clipboard::CONTENT_TYPE}"
                end

                params = {
                  contentType: content_type,
                  content: Base64.strict_encode64(content)
                }
                params[:label] = label unless label.nil?

                execute(:set_clipboard, {}, params)
              end
            end
          end
        end # module Clipboard
      end # module Device
    end # module Android
  end # module Core
end # module Appium
