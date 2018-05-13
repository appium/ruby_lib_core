require_relative 'device/clipboard'

module Appium
  module Core
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

        # @!method get_clipboard(content_type: :plaintext)
        #   Set the content of device's clipboard.
        # @param [String] content_type: one of supported content types.
        # @return [String]
        #
        # @example
        #
        #   @driver.get_clipboard #=> "happy testing"
        #

        # @!method set_clipboard(content:, content_type: :plaintext)
        #   Set the content of device's clipboard.
        # @param [String] content_type: one of supported content types.
        # @param [String] content: Contents to be set. (Will encode with base64-encoded inside this method)
        #
        # @example
        #
        #   @driver.set_clipboard(content: 'happy testing') #=> {"protocol"=>"W3C"}
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

            Clipboard.add_methods
          end
        end
      end # module Device
    end # module iOS
  end # module Core
end # module Appium
