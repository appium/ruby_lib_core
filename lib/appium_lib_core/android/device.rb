module Appium
  module Android
    module Device
      extend Forwardable

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
      # @option [String] The package owning the activity [required]
      # @option [String] The target activity [required]
      # @option opts [String] The package to start before the target package [optional]
      # @option opts [String] The activity to start before the target activity [optional]
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
      # @param [String] package_name Package name
      # @param [String] data_type Data type get with `get_performance_data_types`
      # @param [String] data_read_timeout Command timeout. Default is 2.
      #
      # @example
      #
      #   @driver.get_performance_data package_name: package_name, data_type: data_type, data_read_timeout: 2
      #

      # @!method start_recording_screen(package_name:, data_type:, data_read_timeout: 1000)
      #   Record the display of devices running Android 4.4 (API level 19) and higher.
      #   It records screen activity to an MPEG-4 file. Audio is not recorded with the video file.
      # @param [String] file_path A path to save the video. `/sdcard/default.mp4` is by default.
      # @param [String] video_size A video size. '1280x720' is by default.
      # @param [String] time_limit Recording time. 180 second is by default.
      # @param [String] bit_rate The video bit rate for the video, in megabits per second. 3000000(3Mbps) is by default.
      #
      # @example
      #
      #   @driver.start_recording_screen(file_path: '/sdcard/default.mp4', video_size: '1280x720',
      #                                  time_limit: '180', bit_rate: '3000000')
      #

      # @!method stop_recording_screen
      #   Stop recording the screen.
      #
      # @example
      #
      #   @driver.stop_recording_screen
      #

      ####
      ## class << self
      ####

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

          Appium::Core::Device.add_endpoint_method(:start_recording_screen) do
            def start_recording_screen(file_path: '/sdcard/default.mp4', video_size: '1280x720',
                                       time_limit: '180', bit_rate: '3000000')
              execute(:start_recording_screen, {},
                      filePath: file_path, videoSize: video_size, timeLimit: time_limit, bitRate: bit_rate)
            end
          end
        end
      end
    end # module Device
  end # module Android
end # module Appium
