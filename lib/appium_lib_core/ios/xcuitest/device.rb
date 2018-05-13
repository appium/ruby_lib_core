require_relative 'device/performance'
require_relative 'device/screen'
require_relative 'device/battery'

module Appium
  module Core
    module Ios
      module Xcuitest
        module Device
          extend Forwardable

          # rubocop:disable Metrics/LineLength

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

          # @!method start_recording_screen(remote_path: nil, user: nil, pass: nil, method: nil, force_restart: nil, video_type: 'mp4', time_limit: '180', video_quality: 'medium')
          # @param [String] remote_path: The path to the remote location, where the resulting video should be uploaded.
          #                             The following protocols are supported: http/https, ftp.
          #                             Null or empty string value (the default setting) means the content of resulting
          #                             file should be encoded as Base64 and passed as the endpount response value.
          #                             An exception will be thrown if the generated media file is too big to
          #                             fit into the available process memory.
          #                             This option only has an effect if there is screen recording process in progreess
          #                             and `forceRestart` parameter is not set to `true`.
          # @param [String] user: The name of the user for the remote authentication.
          # @param [String] pass: The password for the remote authentication.
          # @param [String] method: The http multipart upload method name. The 'PUT' one is used by default.
          # @param [Boolean] force_restart: Whether to try to catch and upload/return the currently running screen recording
          #                                 (`false`, the default setting on server) or ignore the result of it
          #                                 and start a new recording immediately (`true`).
          # @param [String] video_type: The format of the screen capture to be recorded.
          #                            Available formats: "h264", "mp4" or "fmp4". Default is "mp4".
          #                            Only works for Simulator.
          # @param [String] time_limit: Recording time. 180 seconds is by default.
          # @param [String] video_quality: The video encoding quality (low, medium, high, photo - defaults to medium).
          #                               Only works for real devices.
          #
          # @example
          #
          #    @driver.start_recording_screen
          #    @driver.start_recording_screen video_type: 'h264', time_limit: '260'
          #

          # @since 1.3.4
          # @!method start_performance_record(timeout: 300000, profile_name: 'Activity Monitor')
          #
          # This is a blocking application.
          # @param [Integer|String] timeout: The maximum count of milliseconds to record the profiling information.
          # @param [String] profile_name: The name of existing performance profile to apply.
          #                               Execute `instruments -s` to show the list of available profiles.
          #                               Note, that not all profiles are supported on mobile devices.
          # @param [Integer|String] pid: The ID of the process to measure the performance for.
          #                              Set it to `current` in order to measure the performance of
          #                              the process, which belongs to the currently active application.
          #                              All processes running on the device are measured if
          #                              pid is unset (the default setting). Setting process ID while
          #                              device under test is Simulator might require `instruments` to be launched
          #                              with sudo privileges, which is not supported and will throw a timeout exception.
          # @return nil
          #
          # @example
          #
          #   @driver.start_performance_record # default: (timeout: 300000, profile_name: 'Activity Monitor')
          #   @driver.start_performance_record(timeout: 300000, profile_name: 'Activity Monitor')
          #

          # @since 1.3.4
          # @!method get_performance_record(save_file_path: './performance', profile_name: 'Activity Monitor', remote_path: nil, user: nil, pass: nil, method: 'PUT')
          #
          # This is a blocking application.
          #
          # @param [String] save_file_path: A path to save data as zipped .trace file
          # @param [String] profile_name: The name of existing performance profile to apply.
          #                               Execute `instruments -s` to show the list of available profiles.
          #                               Note, that not all profiles are supported on mobile devices.
          # @param [String] save_file_path: The name of existing performance profile to apply.
          #                              Execute `instruments -s` to show the list of available profiles.
          #                              Note, that not all profiles are supported on mobile devices.
          # @param [String] remote_path: The path to the remote location, where the resulting zipped .trace file should be uploaded.
          #                              The following protocols are supported: http/https, ftp.
          #                              Null or empty string value (the default setting) means the content of resulting
          #                              file should be zipped, encoded as Base64 and passed as the endpount response value.
          #                              An exception will be thrown if the generated file is too big to
          #                              fit into the available process memory.
          # @param [String] user: The name of the user for the remote authentication. Only works if `remotePath` is provided.
          # @param [String] pass: The password for the remote authentication. Only works if `remotePath` is provided.
          # @param [String] method: The http multipart upload method name. Only works if `remotePath` is provided.
          #
          # @example
          #
          #   @driver.get_performance_record
          #   @driver.get_performance_record(save_file_path: './performance', profile_name: 'Activity Monitor')

          # @since 1.6.0
          # @!method battery_info
          #
          # Get battery information.
          #
          # @return [Hash]  Return battery level and battery state from the target real device. (Simulator has no battery.)
          #                 https://developer.apple.com/documentation/uikit/uidevice/ 's `batteryLevel` and `batteryState`.
          #                 Battery level in range [0.0, 1.0], where 1.0 means 100% charge. -1 is returned
          #                 if the actual value cannot be retrieved from the system.
          #                 Battery state. The following symbols are possible
          #                 `:unplugged, :charging, :full`
          #
          # @example
          #
          #   @driver.battery_info #=> { state: :full, level: 0.7 }
          #

          # rubocop:enable Metrics/LineLength

          ####
          ## class << self
          ####

          class << self
            def extended(_mod)
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

              Performance.add_methods
              Screen.add_methods
              Battery.add_methods
            end
          end # class << self
        end # module Device
      end # module Xcuitest
    end # module Ios
  end # module Core
end # module Appium
