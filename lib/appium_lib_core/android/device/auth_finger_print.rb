module Appium
  module Core
    module Android
      module Device
        module AuthenticatesByFinger
          # @!method finger_print(finger_id)
          #     Authenticate users by using their finger print scans on supported emulators.
          #
          # @param [Integer] finger_id Finger prints stored in Android Keystore system (from 1 to 10)
          #
          # @example
          #
          #   @driver.finger_print 1
          #
          def self.add_methods
            ::Appium::Core::Device.add_endpoint_method(:finger_print) do
              def finger_print(finger_id)
                unless (1..10).cover? finger_id.to_i
                  raise ArgumentError, "finger_id should be integer between 1 to 10. Not #{finger_id}"
                end

                execute(:finger_print, {}, { fingerprintId: finger_id.to_i })
              end
            end
          end # def self.emulator_commands
        end # module Emulator
      end # module Device
    end # module Android
  end # module Core
end # module Appium
