module Appium
  module Android
    module Device
      module Emulator
        GSM_CALL_ACTION = [:call, :accept, :cancel, :hold].freeze

        GSM_VOICE_STATE = [:on, :off, :denied, :searching, :roaming, :home, :unregistered].freeze

        GSM_SIGNAL = { none_or_unknown: 0, poor: 1, moderate: 2, good: 3, great: 4 }.freeze

        NET_SPEED = [:gsm, :scsd, :gprs, :edge, :umts, :hsdpa, :lte, :evdo, :full].freeze

        POWER_AC_STATE = [:on, :off].freeze

        # @!method send_sms(phone_number:, message:)
        #     Emulate send SMS event on the connected emulator.
        #
        # @param [String] phone_number: The phone number of message sender
        # @param [String] message: The message to send
        #
        # @example
        #
        #   @driver.send_sms phone_number: '00000000000', message: 'test message'
        #

        # @!method gsm_call(phone_number:, action:)
        #     Emulate GSM call event on the connected emulator.
        #
        # @param [String] phone_number: The phone number of message sender
        # @param [Hash] action: One of available GSM call actions. Available action is GSM_CALL_ACTION.
        #
        # @example
        #
        #   @driver.gsm_call phone_number: '00000000000', action: :call
        #

        # @!method gsm_signal(signal_strength)
        #     Emulate GSM signal strength change event on the connected emulator.
        #
        # @param [Hash] signal_strength One of available GSM signal strength. Available action is GSM_SIGNAL.
        #
        # @example
        #
        #   @driver.gsm_signal :good
        #

        # @!method gsm_voice(state)
        #     Emulate GSM voice event on the connected emulator.
        #
        # @param [Hash] state One of available GSM voice state. Available action is GSM_VOICE_STATE.
        #
        # @example
        #
        #   @driver.gsm_voice :on
        #

        # @!method set_network_speed(netspeed)
        #     Emulate network speed change event on the connected emulator.
        #
        # @param [Hash] netspeed One of available Network Speed values. Available action is NET_SPEED.
        #
        # @example
        #
        #   @driver.set_network_speed :gsm
        #

        # @!method set_power_capacity(percent)
        #     Emulate power capacity change on the connected emulator.
        #
        # @param [Integer] percent Percentage value in range [0, 100].
        #
        # @example
        #
        #   @driver.set_power_capacity 10
        #

        # @!method set_power_ac(state)
        #     Emulate power state change on the connected emulator.
        #
        # @param [Hash] state One of available power AC state. Available action is POWER_AC_STATE.
        #
        # @example
        #
        #   @driver.set_power_ac :on
        #
        def self.emulator_commands
          Appium::Core::Device.add_endpoint_method(:send_sms) do
            def send_sms(phone_number:, message:)
              execute(:send_sms, {}, { phoneNumber: phone_number, message: message })
            end
          end

          Appium::Core::Device.add_endpoint_method(:gsm_call) do
            def gsm_call(phone_number:, action:)
              unless GSM_CALL_ACTION.member? action.to_sym
                raise "action: should be member of #{GSM_CALL_ACTION}. Not #{action}."
              end

              execute(:gsm_call, {}, { phoneNumber: phone_number, action: action })
            end
          end

          Appium::Core::Device.add_endpoint_method(:gsm_signal) do
            def gsm_signal(signal_strength)
              raise "#{signal_strength} should be member of #{GSM_SIGNAL} " if GSM_SIGNAL[signal_strength.to_sym].nil?

              execute(:gsm_signal, {}, { signalStrengh: GSM_SIGNAL[signal_strength] })
            end
          end

          Appium::Core::Device.add_endpoint_method(:gsm_voice) do
            def gsm_voice(state)
              unless GSM_VOICE_STATE.member? state.to_sym
                raise "The state should be member of #{GSM_VOICE_STATE}. Not #{state}."
              end

              execute(:gsm_voice, {}, { state: state })
            end
          end

          Appium::Core::Device.add_endpoint_method(:set_network_speed) do
            def set_network_speed(netspeed)
              unless NET_SPEED.member? netspeed.to_sym
                raise "The netspeed should be member of #{NET_SPEED}. Not #{netspeed}."
              end

              execute(:set_network_speed, {}, { netspeed: netspeed })
            end
          end

          Appium::Core::Device.add_endpoint_method(:set_power_capacity) do
            def set_power_capacity(percent)
              unless (0..100).member? percent
                raise "The  percent should be between 0 and 100. Not #{percent}."
              end

              execute(:set_power_capacity, {}, { percent: percent })
            end
          end

          Appium::Core::Device.add_endpoint_method(:set_power_ac) do
            def set_power_ac(state)
              unless POWER_AC_STATE.member? state.to_sym
                raise "The state should be member of #{POWER_AC_STATE}. Not #{state}."
              end

              execute(:set_power_ac, {}, { state: state })
            end
          end
        end # def self.emulator_commands
      end # module Emulator
    end # module Device
  end # module Android
end # module Appium
