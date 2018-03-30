require_relative 'device/emulator'
require 'base64'

module Appium
  module Android
    module Device
      extend Forwardable

      # rubocop:disable Metrics/LineLength

      # @!method hide_keyboard(close_key = nil, strategy = nil)
      # Hide the onscreen keyboard
      # @param [String] close_key The name of the key which closes the keyboard.
      #   Defaults to 'Done' for iOS(except for XCUITest).
      # @param [Symbol] strategy The symbol of the strategy which closes the keyboard.
      #   XCUITest ignore this argument.
      #   Default for iOS is `:pressKey`. Default for Android is `:tapOutside`.
      #
      # @example
      #
      #  @driver.hide_keyboard                   # Close a keyboard with the 'Done' button
      #  @driver.hide_keyboard('Finished')       # Close a keyboard with the 'Finished' button
      #  @driver.hide_keyboard(nil, :tapOutside) # Close a keyboard with tapping out side of keyboard
      #

      # @!method end_coverage(path, intent)
      # Android only;  Ends the test coverage and writes the results to the given path on device.
      # @param [String] path Path on the device to write too.
      # @param [String] intent Intent to broadcast when ending coverage.
      #

      # @!method start_activity(opts)
      # Android only. Start a new activity within the current app or launch a new app and start the target activity.
      #
      # @param opts [Hash] Options
      # @option opts [String] :app_package The package owning the activity [required]
      # @option opts [String] :app_activity The target activity [required]
      # @option opts [String] :app_wait_package The package to start before the target package [optional]
      # @option opts [String] :app_wait_activity The activity to start before the target activity [optional]
      #
      # @example
      #
      #   start_activity app_package: 'io.appium.android.apis',
      #     app_activity: '.accessibility.AccessibilityNodeProviderActivity'
      #

      # @!method set_network_connection(mode)
      # Set the device network connection mode
      # @param [String] mode Bit mask that represent the network mode
      #
      #   Value (Alias)      | Data | Wifi | Airplane Mode
      #   -------------------------------------------------
      #   1 (Airplane Mode)  | 0    | 0    | 1
      #   6 (All network on) | 1    | 1    | 0
      #   4 (Data only)      | 1    | 0    | 0
      #   2 (Wifi only)      | 0    | 1    | 0
      #   0 (None)           | 0    | 0    | 0
      #
      # @example
      #
      #   @driver.set_network_connection 1
      #   @driver.network_connection_type = 1
      #

      # @!method get_performance_data_types
      #   Get the information type of the system state which is supported to read such as
      #   cpu, memory, network, battery via adb commands.
      #   https://github.com/appium/appium-base-driver/blob/be29aec2318316d12b5c3295e924a5ba8f09b0fb/lib/mjsonwp/routes.js#L300
      #
      # @example
      #
      #   @driver.get_performance_data_types #=> ["cpuinfo", "batteryinfo", "networkinfo", "memoryinfo"]
      #

      # @!method get_performance_data(package_name:, data_type:, data_read_timeout: 1000)
      #   Get the resource usage information of the application.
      #   https://github.com/appium/appium-base-driver/blob/be29aec2318316d12b5c3295e924a5ba8f09b0fb/lib/mjsonwp/routes.js#L303
      # @param [String] package_name: Package name
      # @param [String] data_type: Data type get with `get_performance_data_types`
      # @param [String] data_read_timeout: Command timeout. Default is 2.
      #
      # @example
      #
      #   @driver.get_performance_data package_name: package_name, data_type: data_type, data_read_timeout: 2
      #

      # @!method start_recording_screen(remote_path: nil, user: nil, pass: nil, method: 'PUT', force_restart: nil, video_size: nil, time_limit: '180', bit_rate: '4000000')
      # @param [String] remote_path: The path to the remote location, where the resulting video should be uploaded.
      #                             The following protocols are supported: http/https, ftp.
      #                             Null or empty string value (the default setting) means the content of resulting
      #                             file should be encoded as Base64 and passed as the endpoint response value.
      #                             An exception will be thrown if the generated media file is too big to
      #                             fit into the available process memory.
      #                             This option only has an effect if there is screen recording process in progress
      #                             and `forceRestart` parameter is not set to `true`.
      # @param [String] user: The name of the user for the remote authentication.
      # @param [String] pass: The password for the remote authentication.
      # @param [String] method: The http multipart upload method name. The 'PUT' one is used by default.
      # @param [Boolean] force_restart: Whether to try to catch and upload/return the currently running screen recording
      #                                 (`false`, the default setting on server) or ignore the result of it
      #                                 and start a new recording immediately (`true`).
      #
      # @param [String] video_size: The format is widthxheight.
      #                             The default value is the device's native display resolution (if supported),
      #                             1280x720 if not. For best results,
      #                             use a size supported by your device's Advanced Video Coding (AVC) encoder.
      #                             For example, "1280x720"
      # @param [String] time_limit: Recording time. 180 seconds is by default.
      # @param [String] bit_rate: The video bit rate for the video, in megabits per second.
      #                           4 Mbp/s(4000000) is by default for Android API level below 27. 20 Mb/s(20000000) for API level 27 and above.
      # @param [Boolean] bug_report: Set it to `true` in order to display additional information on the video overlay,
      #                              such as a timestamp, that is helpful in videos captured to illustrate bugs.
      #                              This option is only supported since API level 27 (Android P).
      #
      # @example
      #
      #    @driver.start_recording_screen
      #    @driver.start_recording_screen video_size: '1280x720', time_limit: '180', bit_rate: '5000000'
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

      # @!method set_clipboard(content:, content_type: :plaintext, label: nil)
      #   Set the content of device's clipboard.
      # @param [String] label: clipboard data label.
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

      # rubocop:enable Metrics/LineLength

      class << self
        def extended(_mod)
          Appium::Core::Device.extend_webdriver_with_forwardable

          # Android
          Appium::Core::Device.add_endpoint_method(:start_activity) do
            def start_activity(opts)
              raise 'opts must be a hash' unless opts.is_a? Hash
              app_package = opts[:app_package]
              raise 'app_package is required' unless app_package
              app_activity = opts[:app_activity]
              raise 'app_activity is required' unless app_activity
              app_wait_package  = opts.fetch(:app_wait_package, '')
              app_wait_activity = opts.fetch(:app_wait_activity, '')

              unknown_opts = opts.keys - %i(app_package app_activity app_wait_package app_wait_activity)
              raise "Unknown options #{unknown_opts}" unless unknown_opts.empty?

              execute :start_activity, {}, appPackage: app_package,
                                           appActivity: app_activity,
                                           appWaitPackage: app_wait_package,
                                           appWaitActivity: app_wait_activity
            end
          end

          # Android, Override
          Appium::Core::Device.add_endpoint_method(:hide_keyboard) do
            def hide_keyboard(close_key = nil, strategy = nil)
              option = {}

              option[:key] = close_key if close_key
              option[:strategy] = strategy || :tapOutside # default to pressKey

              execute :hide_keyboard, {}, option
            end
          end

          # TODO: TEST ME
          Appium::Core::Device.add_endpoint_method(:end_coverage) do
            def end_coverage(path, intent)
              execute :end_coverage, {}, path: path, intent: intent
            end
          end

          Appium::Core::Device.add_endpoint_method(:set_network_connection) do
            def set_network_connection(mode)
              execute :set_network_connection, {}, type: mode
            end
          end

          Appium::Core::Device.add_endpoint_method(:get_performance_data) do
            def get_performance_data(package_name:, data_type:, data_read_timeout: 1000)
              execute(:get_performance_data, {},
                      packageName: package_name, dataType: data_type, dataReadTimeout: data_read_timeout)
            end
          end

          add_screen_recording
          add_clipboard
          Emulator.emulator_commands
        end

        private

        def add_screen_recording
          Appium::Core::Device.add_endpoint_method(:start_recording_screen) do
            # rubocop:disable Metrics/ParameterLists
            def start_recording_screen(remote_path: nil, user: nil, pass: nil, method: 'PUT', force_restart: nil,
                                       video_size: nil, time_limit: '180', bit_rate: nil, bug_report: nil)
              option = ::Appium::Core::Device::ScreenRecord.new(
                remote_path: remote_path, user: user, pass: pass, method: method, force_restart: force_restart
              ).upload_option

              option[:videoSize] = video_size unless video_size.nil?
              option[:timeLimit] = time_limit
              option[:bitRate] = bit_rate unless bit_rate.nil?

              unless bug_report.nil?
                raise 'bug_report should be true or false' unless [true, false].member?(bug_report)
                option[:bugReport] = bug_report
              end

              execute(:start_recording_screen, {}, { options: option })
            end
            # rubocop:enable Metrics/ParameterLists
          end
        end

        def add_clipboard
          ::Appium::Core::Device.add_endpoint_method(:get_clipboard) do
            def get_clipboard(content_type: :plaintext)
              unless ::Appium::Core::Device::Clipboard::CONTENT_TYPE.member?(content_type)
                raise "content_type should be #{::Appium::Core::Device::Clipboard::CONTENT_TYPE}"
              end

              params = { contentType: content_type }

              data = execute(:get_clipboard, {}, params)
              Base64.decode64 data
            end
          end

          ::Appium::Core::Device.add_endpoint_method(:set_clipboard) do
            def set_clipboard(content:, content_type: :plaintext, label: nil)
              unless ::Appium::Core::Device::Clipboard::CONTENT_TYPE.member?(content_type)
                raise "content_type should be #{::Appium::Core::Device::Clipboard::CONTENT_TYPE}"
              end

              params = {
                contentType: content_type,
                content: Base64.encode64(content)
              }
              params[:label] = label unless label.nil?

              execute(:set_clipboard, {}, params)
            end
          end
        end
      end
    end # module Device
  end # module Android
end # module Appium
