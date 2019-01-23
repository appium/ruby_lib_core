require_relative 'device/emulator'
require_relative 'device/clipboard'
require_relative 'device/network'
require_relative 'device/performance'
require_relative 'device/screen'
require_relative 'device/auth_finger_print'

module Appium
  module Core
    module Android
      module Device
        extend Forwardable

        # rubocop:disable Metrics/LineLength

        # @!method open_notifications
        #   Open Android notifications
        #
        # @example
        #
        #   @driver.open_notifications
        #

        # @!method current_activity
        # Get current activity name
        # @return [String] An activity name
        #
        # @example
        #
        #   @driver.current_activity # '.ApiDemos'
        #

        # @!method current_package
        # Get current package name
        # @return [String] A package name
        #
        # @example
        #
        #   @driver.current_package # 'com.example.android.apis'
        #

        # @!method get_system_bars
        # Get system bar's information
        # @return [String]
        #
        # @example
        #
        #   @driver.get_system_bars
        #

        # @!method get_display_density
        # Get connected device's density.
        # @return [Integer] The size of density
        #
        # @example
        #
        #   @driver.get_display_density # 320
        #

        # @!method get_network_connection
        #   Get the device network connection current status
        #   See set_network_connection method for return value
        #   Same as `#network_connection_type` in selenium-webdriver.
        #
        #   Returns a key of {:airplane_mode: 1, wifi: 2, data: 4, all: 6, none: 0} in `#network_connection_type`
        #   Returns a number of the mode in `#get_network_connection`
        #
        # @example
        #
        #   @driver.network_connection_type #=> :all
        #   @driver.get_network_connection  #=> 6
        #

        # @!method toggle_wifi
        #   Switch the state of the wifi service only for Android
        #
        # @return [String]
        #
        # @example
        #
        #   @driver.toggle_wifi
        #

        # @!method toggle_data
        #   Switch the state of data service only for Android, and the device should be rooted
        #
        # @return [String]
        #
        # @example
        #
        #   @driver.toggle_data
        #

        # @!method toggle_location_services
        #   Switch the state of the location service
        #
        # @return [String]
        #
        # @example
        #
        #   @driver.toggle_location_services
        #

        # @!method toggle_airplane_mode
        # Toggle flight mode on or off
        #
        # @example
        #
        #   @driver.toggle_airplane_mode
        #

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
        # Same as `#network_connection_type` in selenium-webdriver.
        #
        # @param [String] mode Bit mask that represent the network mode
        # Or the key matched with `{:airplane_mode: 1, wifi: 2, data: 4, all: 6, none: 0}`
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
        #   @driver.set_network_connection :airplane_mode
        #   @driver.network_connection_type = :airplane_mode # As selenium-webdriver
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
        #                             Since Appium 1.8.2 the time limit can be up to 1800 seconds (30 minutes).
        #                             Appium will automatically try to merge the 3-minutes chunks recorded
        #                             by the screenrecord utility, however, this requires FFMPEG utility
        #                             to be installed and available in PATH on the server machine. If the utility is not
        #                             present then the most recent screen recording chunk is going to be returned as the result.
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

        # @!method finger_print(finger_id)
        #     Authenticate users by using their finger print scans on supported emulators.
        #
        # @param [Integer] finger_id Finger prints stored in Android Keystore system (from 1 to 10)
        #
        # @example
        #
        #   @driver.finger_print 1
        #

        ####
        ## class << self
        ####

        # rubocop:enable Metrics/LineLength

        class << self
          def extended(_mod)
            ::Appium::Core::Device.extend_webdriver_with_forwardable

            ::Appium::Core::Device.add_endpoint_method(:open_notifications) do
              def open_notifications
                execute :open_notifications
              end
            end

            ::Appium::Core::Device.add_endpoint_method(:current_activity) do
              def current_activity
                execute :current_activity
              end
            end

            ::Appium::Core::Device.add_endpoint_method(:current_package) do
              def current_package
                execute :current_package
              end
            end

            ::Appium::Core::Device.add_endpoint_method(:get_system_bars) do
              def get_system_bars
                execute :get_system_bars
              end
            end

            ::Appium::Core::Device.add_endpoint_method(:toggle_location_services) do
              def toggle_location_services
                execute :toggle_location_services
              end
            end

            ::Appium::Core::Device.add_endpoint_method(:start_activity) do
              def start_activity(opts)
                raise 'opts must be a hash' unless opts.is_a? Hash

                option = {}

                app_package = opts[:app_package]
                raise 'app_package is required' unless app_package

                app_activity = opts[:app_activity]
                raise 'app_activity is required' unless app_activity

                option[:appPackage] = app_package
                option[:appActivity] = app_activity

                app_wait_package  = opts.fetch(:app_wait_package, nil)
                app_wait_activity = opts.fetch(:app_wait_activity, nil)
                option[:appWaitPackage] = app_wait_package if app_wait_package
                option[:appWaitActivity] = app_wait_activity if app_wait_activity

                unknown_opts = opts.keys - %i(app_package app_activity app_wait_package app_wait_activity)
                raise "Unknown options #{unknown_opts}" unless unknown_opts.empty?

                execute :start_activity, {}, option
              end
            end

            # Android, Override
            ::Appium::Core::Device.add_endpoint_method(:hide_keyboard) do
              def hide_keyboard(close_key = nil, strategy = nil)
                option = {}

                option[:key] = close_key if close_key
                option[:strategy] = strategy if strategy

                execute :hide_keyboard, {}, option
              end
            end

            # TODO: TEST ME
            ::Appium::Core::Device.add_endpoint_method(:end_coverage) do
              def end_coverage(path, intent)
                execute :end_coverage, {}, path: path, intent: intent
              end
            end

            Screen.add_methods
            Performance.add_methods
            Network.add_methods
            Clipboard.add_methods
            Emulator.add_methods
            Authentication.add_methods
          end
        end
      end # module Device
    end # module Android
  end
end # module Appium
