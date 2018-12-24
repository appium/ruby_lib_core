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
