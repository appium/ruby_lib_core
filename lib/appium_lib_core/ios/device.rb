require 'base64'

module Appium
  module Ios
    module Device
      extend Forwardable

      # @!method touch_id(match = true)
      # An instance method of Appium::Core::Device .
      # Simulate Touch ID with either valid (match == true) or invalid (match == false) fingerprint.
      # @param [Boolean] match fingerprint validity. Defaults to true.
      # @return [String]
      #
      # @example
      #
      #   @driver.touch_id true #=> Simulate valid fingerprint
      #   @driver.touch_id false #=> Simulate invalid fingerprint
      #

      # @!method toggle_touch_id_enrollment(enabled = true)
      # An instance method of Appium::Core::Device .
      # Toggle touch id enrollment on an iOS Simulator.
      # @param [Boolean] enabled Enable toggle touch id enrollment. Set true by default.
      # @return [String]
      #
      # @example
      #
      #   @driver.toggle_touch_id_enrollment       #=> Enable toggle enrolled
      #   @driver.toggle_touch_id_enrollment true  #=> Enable toggle enrolled
      #   @driver.toggle_touch_id_enrollment false #=> Disable toggle enrolled
      #

      ####
      ## class << self
      ####

      class << self
        def extended(_mod)
          ::Appium::Core::Device.extend_webdriver_with_forwardable

          ::Appium::Core::Device.add_endpoint_method(:touch_id) do
            def touch_id(match = true)
              execute :touch_id, {}, match: match
            end
          end

          ::Appium::Core::Device.add_endpoint_method(:toggle_touch_id_enrollment) do
            def toggle_touch_id_enrollment(enabled = true)
              execute :toggle_touch_id_enrollment, {}, enabled: enabled
            end
          end

          add_clipboard
        end

        private

        def add_clipboard
          ::Appium::Core::Device.add_endpoint_method(:get_clipboard) do
            def get_clipboard(content_type: :plaintext)
              raise 'content_type should be [:plaintext, :image, :url]' unless [:plaintext, :image, :url].member?(content_type)

              params = {}
              params[:contentType] = content_type

              data = execute(:get_clipboard, {}, params)
              Base64.decode64 data
            end
          end

          ::Appium::Core::Device.add_endpoint_method(:set_clipboard) do
            def set_clipboard(content:, content_type: :plaintext)
              raise 'content_type should be [:plaintext, :image, :url]' unless [:plaintext, :image, :url].member?(content_type)

              params = {
                contentType: content_type,
                content: Base64.encode64(content)
              }

              execute(:set_clipboard, {}, params)
            end
          end
        end
      end
    end # module Device
  end # module iOS
end # module Appium
