module Appium
  module Ios
    module Xcuitest
      module Device
        extend Forwardable

        # @!method hide_keyboard(close_key = nil, strategy = nil)
        # Hide the onscreen keyboard
        # @param [String] close_key The name of the key which closes the keyboard.
        # @param [Symbol] strategy The symbol of the strategy which closes the keyboard.
        #   XCUITest ignore this argument.
        #   Default for iOS is `:pressKey`. Default for Android is `:tapOutside`.
        #
        # @example
        #
        #  @driver.hide_keyboard             # Close a keyboard with the 'Done' button
        #  @driver.hide_keyboard('Finished') # Close a keyboard with the 'Finished' button
        #

        # @!method background_app(duration = 0)
        # Backgrounds the app for a set number of seconds.
        # This is a blocking application.
        # @param [Integer] duration How many seconds to background the app for.
        #
        # @example
        #
        #   @driver.background_app
        #   @driver.background_app(5)
        #   @driver.background_app(-1) #=> the app never come back. https://github.com/appium/appium/issues/7741
        #

        # @!method start_recording_screen(remote_path:, user:, pass:, method:, force_restart:,
        #                                 video_type:, time_limit:, video_quality:)
        #
        # @option [String] remote_path The path to the remote location, where the resulting video should be uploaded.
        #                             The following protocols are supported: http/https, ftp.
        #                             Null or empty string value (the default setting) means the content of resulting
        #                             file should be encoded as Base64 and passed as the endpount response value.
        #                             An exception will be thrown if the generated media file is too big to
        #                             fit into the available process memory.
        #                             This option only has an effect if there is screen recording process in progreess
        #                             and `forceRestart` parameter is not set to `true`.
        # @option [String] user The name of the user for the remote authentication.
        # @option [String] pass The password for the remote authentication.
        # @option [String] method The http multipart upload method name. The 'PUT' one is used by default.
        # @option [Boolean] force_restart Whether to try to catch and upload/return the currently running screen recording
        #                                 (`false`, the default setting on server) or ignore the result of it
        #                                 and start a new recording immediately (`true`).
        #
        # @param [String] video_type The format of the screen capture to be recorded.
        #                            Available formats: "h264", "mp4" or "fmp4". Default is "mp4".
        #                            Only works for Simulator.
        # @param [String] time_limit Recording time. 180 seconds is by default.
        # @param [String] video_quality The video encoding quality (low, medium, high, photo - defaults to medium).
        #                               Only works for real devices.
        #
        # @example
        #
        #    @driver.start_recording_screen
        #    @driver.start_recording_screen video_type: 'h264', time_limit: '260'
        #

        ####
        ## class << self
        ####

        class << self
          def extended(_mod)
            ::Appium::Core::Device.extend_webdriver_with_forwardable

            # Override
            ::Appium::Core::Device.add_endpoint_method(:hide_keyboard) do
              def hide_keyboard(close_key = nil, strategy = nil)
                option = {}

                option[:key] = close_key if close_key
                option[:strategy] = strategy if strategy

                execute :hide_keyboard, {}, option
              end
            end

            # Override
            ::Appium::Core::Device.add_endpoint_method(:background_app) do
              def background_app(duration = 0)
                # https://github.com/appium/ruby_lib/issues/500, https://github.com/appium/appium/issues/7741
                # `execute :background_app, {}, seconds: { timeout: duration_milli_sec }` works over Appium 1.6.4
                duration_milli_sec = duration.nil? ? nil : duration * 1000
                execute :background_app, {}, seconds: { timeout: duration_milli_sec }
              end
            end

            add_screen_recording
          end

          private

          def add_screen_recording
            Appium::Core::Device.add_endpoint_method(:start_recording_screen) do
              # rubocop:disable Metrics/ParameterLists
              def start_recording_screen(remote_path: nil, user: nil, pass: nil, method: nil, force_restart: nil,
                                         video_type: 'mp4', time_limit: '180', video_quality: 'medium')
                option = ::Appium::Core::Device::ScreenRecord.new(
                  remote_path: remote_path, user: user, pass: pass, method: method, force_restart: force_restart
                ).upload_option

                option[:videoType] = video_type
                option[:timeLimit] = time_limit
                option[:videoQuality] = video_quality

                execute(:start_recording_screen, {}, { options: option })
              end
              # rubocop:enable Metrics/ParameterLists
            end
          end
        end # class << self
      end # module Device
    end # module Xcuitest
  end # module Ios
end # module Appium
