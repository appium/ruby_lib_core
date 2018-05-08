require_relative 'common/touch_action/touch_actions'
require_relative 'common/touch_action/multi_touch'
require_relative 'device/screen_record'
require_relative 'device/app_state'
require_relative 'device/clipboard_content_type'
require_relative 'device/image_comparison'

require 'base64'

module Appium
  module Core
    module Device
      extend Forwardable

      # rubocop:disable Metrics/LineLength

      ####
      ## No argument
      ####

      # @!method launch_app
      # Start the simulator and application configured with desired capabilities
      #
      # @example
      #
      #   @driver.launch_app
      #

      # @!method close_app
      # Close an app on device
      #
      # @example
      #
      #   @driver.close_app
      #

      # @!method reset
      # Reset the device, relaunching the application.
      #
      # @example
      #
      #   @driver.reset
      #

      # @!method shake
      # Cause the device to shake
      #
      # @example
      #
      #   @driver.shake
      #

      # @!method unlock
      # Unlock the device
      #
      # @example
      #
      #   @driver.unlock
      #

      # @!method device_locked?
      # Check current device status is weather locked or not
      #
      # @example
      #
      #   @driver.device_locked?
      #

      # @!method device_time
      #   Get the time on the device
      #
      # @return [String]
      #
      # @example
      #
      #   @driver.device_time
      #

      ####
      ## With arguments
      ####

      # @!method install_app(path, replace: nil, timeout: nil, allow_test_packages: nil, use_sdcard: nil, grant_permissions: nil)
      # Install the given app onto the device
      #
      # @param [String] path The absolute local path or remote http URL to an .ipa or .apk file, or a .zip containing one of these.
      # @param [Boolean] replace: Only for Android. Whether to reinstall/upgrade the package if it is already present on the device under test. `true` by default
      # @param [Integer] timeout: Only for Android. How much time to wait for the installation to complete. 60000ms by default.
      # @param [Boolean] allow_test_packages: Only for Android. Whether to allow installation of packages marked as test in the manifest. `false` by default
      # @param [Boolean] use_sdcard: Only for Android. Whether to use the SD card to install the app. `false` by default
      # @param [Boolean] grant_permissions:  Only for Android. whether to automatically grant application permissions on Android 6+ after the installation completes. `false` by default
      #
      # @example
      #
      #   @driver.install_app("/path/to/test.apk")
      #   @driver.install_app("/path/to/test.apk", replace: true, timeout: 20000, allow_test_packages: true, use_sdcard: false, grant_permissions: false)
      #

      # @!method remove_app(app_id, keep_data: nil, timeout: nil)
      #
      # @param [Strong] app_id BundleId for iOS or package name for Android
      # @param [Boolean] keep_data: Only for Android. Whether to keep application data and caches after it is uninstalled. `false` by default
      # @param [Integer] timeout: Only for Android. How much time to wait for the uninstall to complete. 20000ms by default.
      #
      # @example
      #
      #   @driver.remove_app("io.appium.bundle")
      #   @driver.remove_app("io.appium.bundle", keep_data: false, timeout, 10000)
      #

      # @!method app_installed?(app_id)
      # Check whether the specified app is installed on the device
      # @return [Boolean]
      #
      # @example
      #
      #   @driver.app_installed?("io.appium.bundle")
      #

      # @!method terminate_app(app_id)
      # Terminate the specified app.
      #
      # @param [Strong] app_id BundleId for iOS or package name for Android
      # @param [Integer] timeout: Only for Android. How much time to wait for the application termination to complete. 500ms by default.
      # @return [Boolean]
      #
      # @example
      #
      #   @driver.terminate_app("io.appium.bundle") # true
      #   @driver.terminate_app("io.appium.bundle", timeout: 500)
      #

      # @!method activate_app(app_id)
      # Activate(Launch) the specified app.
      # @return [Hash]
      #
      # @example
      #
      #   @driver.activate_app("io.appium.bundle") #=> {}
      #

      # Get the status of an existing application on the device.
      # State:
      #   :not_installed : The current application state cannot be determined/is unknown
      #   :not_running : The application is not running
      #   :running_in_background_suspended : The application is running in the background and is suspended
      #   :running_in_background : The application is running in the background and is not suspended
      #   :running_in_foreground : The application is running in the foreground
      #
      # For more details: https://developer.apple.com/documentation/xctest/xcuiapplicationstate
      #
      # @param [String] bundle_id A target app's bundle id
      # @return [AppState::STATUS] A number of the state
      #
      # @example
      #
      #      @driver.app_state("io.appium.bundle") #=> :not_running
      #

      # @!method app_strings(language = nil)
      # Return the hash of all localization strings.
      # @return [Hash]
      #
      # @example
      #
      #   @driver.app_strings #=> "TransitionsTitle"=>"Transitions", "WebTitle"=>"Web"
      #

      # @!method lock(duration = nil)
      # Lock the device
      # @return [String]
      #
      # @example
      #
      #   @driver.lock    #=> Lock the device
      #   @driver.lock(5) #=> Lock the device in 5 sec and unlock the device after 5 sec.
      #                   #   Block other commands during locking the device.
      #

      # @!method background_app(duration = 0)
      # Backgrounds the app for a set number of seconds.
      # This is a blocking application
      # @param [Integer] duration How many seconds to background the app for.
      # @return [String]
      #
      # @example
      #
      #   @driver.background_app
      #   @driver.background_app(5)
      #   @driver.background_app(-1) #=> the app never come back. https://github.com/appium/appium/issues/7741
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
      #   @driver.hide_keyboard # Close a keyboard with the 'Done' button
      #   @driver.hide_keyboard('Finished') # Close a keyboard with the 'Finished' button
      #   @driver.hide_keyboard(nil, :tapOutside) # Close a keyboard with tapping out side of keyboard
      #

      # @!method is_keyboard_shown
      # Get whether keyboard is displayed or not.
      # @return [Boolean] Return true if keyboard is shown. Return false if keyboard is hidden.
      #
      # @example
      #   @driver.is_keyboard_shown # false
      #

      # @!method keyevent(key, metastate = nil)
      # Send keyevent on the device.(Only for Selendroid)
      # http://developer.android.com/reference/android/view/KeyEvent.html
      # @param [integer] key The key to press.
      # @param [String] metastate The state the metakeys should be in when pressing the key.
      #
      # @example
      #
      #   @driver.keyevent 82
      #

      # @!method press_keycode(key, metastate = nil, flags: nil)
      # Press keycode on the device.
      # http://developer.android.com/reference/android/view/KeyEvent.html
      # @param [integer] key The key to press.
      # @param [String] metastate The state the metakeys should be in when pressing the key.
      # @param [String] flags: Native Android flag value. Several flags can be combined into a single key event.
      #
      # @example
      #
      #   @driver.press_keycode 82
      #

      # @!method long_press_keycode(key, metastate = nil, flags: nil)
      # Long press keycode on the device.
      # http://developer.android.com/reference/android/view/KeyEvent.html
      # @param [integer] key The key to long press.
      # @param [String] metastate The state the metakeys should be in when long pressing the key.
      # @param [String] flags: Native Android flag value. Several flags can be combined into a single key event.
      #
      # @example
      #
      #   @driver.long_press_keycode 82
      #

      # @!method push_file(path, filedata)
      # Place a file in a specific location on the device.
      # @param [String] path The absolute path on the device to store data at.
      # @param [String] filedata Raw file data to be sent to the device. Converted to base64 in the method.
      #
      # @example
      #
      #   @driver.push_file "/file/to/path", "data"
      #

      # @!method pull_file(path)
      # Retrieve a file from the device.  This can retrieve an absolute path or
      # a path relative to the installed app (iOS only).
      # @param [String] path Either an absolute path OR, for iOS devices, a path relative to the app, as described.
      #
      # @example
      #
      #   @driver.pull_file '/local/data/some/path'     #=> Get the file at that path
      #   @driver.pull_file 'Shenanigans.app/some/file' #=> Get 'some/file' from the install location of Shenanigans.app
      #

      # @!method pull_folder(path)
      # Retrieve a folder from the device.
      # @param [String] path absolute path to the folder
      #
      # @example
      #
      #   @driver.pull_folder '/data/local/tmp' #=> Get the folder at that path
      #

      # @!method get_settings
      # Get appium Settings for current test session
      #
      # @example
      #
      #   @driver.pull_folder '/data/local/tmp' #=> Get the folder at that path
      #

      # @since 1.3.4
      # @!method save_viewport_screenshot
      # Save screenshot except for status bar while `@driver.save_screenshot` save entire screen.
      #
      # @example
      #
      #   @driver.save_viewport_screenshot 'path/to/save.png' #=> Get the File instance of viewport_screenshot
      #

      # @!method update_settings(settings)
      # Update Appium Settings for current test session
      # @param [Hash] settings Settings to update, keys are settings, values to value to set each setting to
      #
      # @example
      #
      #   @driver.update_settings('allowInvisibleElements': true)
      #

      # @!method set_immediate_value(element, *value)
      #   Set the value to element directly
      #
      # @example
      #
      #   set_immediate_value element, 'hello'
      #

      # @!method replace_value(element, *value)
      #   Replace the value to element directly
      #
      # @example
      #
      #   replace_value element, 'hello'
      #

      # @!method ime_activate(ime_name)
      # Android only. Make an engine that is available active.
      # @param [String] ime_name The IME owning the activity [required]
      #
      # @example
      #
      #   ime_activate engine: 'com.android.inputmethod.latin/.LatinIME'
      #

      # @!method ime_available_engines
      # Android only. List all available input engines on the machine.
      #
      # @example
      #
      #   ime_available_engines #=> Get the list of IME installed in the target device
      #

      # @!method ime_active_engine
      # Android only. Get the name of the active IME engine.
      #
      # @example
      #
      #   ime_active_engine #=> Get the current active IME such as 'com.android.inputmethod.latin/.LatinIME'
      #

      # @!method ime_activated
      #   Android only. Indicates whether IME input is active at the moment (not if it is available).
      #
      # @example
      #
      #   ime_activated #=> True if IME is activated
      #

      # @!method ime_deactivate
      # Android only. De-activates the currently-active IME engine.
      #
      # @example
      #
      #   ime_deactivate #=> Deactivate current IME engine
      #

      # @!method set_context(context)
      # Change the context to the given context.
      # @param [String] context The context to change to
      #
      # @example
      #
      #   @driver.set_context "NATIVE_APP"
      #

      # @!method current_context
      # @return [String] The context currently being used.
      #
      # @example
      #
      #   @driver.current_context
      #

      # @!method available_contexts
      # @return [Array<String>] All usable contexts, as an array of strings.
      #
      # @example
      #
      #   @driver.available_contexts
      #

      # Perform a block within the given context, then switch back to the starting context.
      # @param [String] context The context to switch to for the duration of the block.
      #
      # @example
      #
      #   result = @driver.within_context('NATIVE_APP') do
      #     @driver.find_element :tag, "button"
      #   end # The result of `find_element :tag, "button"`
      #

      # Change to the default context. This is equivalent to `set_context nil`.
      #
      # @example
      #
      #   @driver.switch_to_default_context
      #

      # @!method take_element_screenshot(element, png_path)
      # @param [Selenium::WebDriver::Element] element A element you'd like to take screenshot.
      # @param [String] png_path A path to save the screenshot
      # @return [File] Path to the screenshot.
      #
      # @example
      #
      #   @driver.take_element_screenshot(element, "fine_name.png")
      #

      # @!method stop_recording_screen(remote_path: nil, user: nil, pass: nil, method: 'PUT')
      # @param [String] remote_path: The path to the remote location, where the resulting video should be uploaded.
      #                             The following protocols are supported: http/https, ftp.
      #                             Null or empty string value (the default setting) means the content of resulting
      #                             file should be encoded as Base64 and passed as the endpoint response value.
      #                             An exception will be thrown if the generated media file is too big to
      #                             fit into the available process memory.
      # @param [String] user: The name of the user for the remote authentication.
      # @param [String] pass: The password for the remote authentication.
      # @param [String] method: The http multipart upload method name. The 'PUT' one is used by default.
      #
      # @example
      #
      #    @driver.stop_recording_screen
      #    @driver.stop_recording_screen remote_path: 'https://example.com', user: 'example', pass: 'pass', method: 'POST'
      #

      # @!method stop_and_save_recording_screen(file_path)
      # @param [String] file_path The path to save video decoded from base64 from Appium server.
      #
      # @example
      #
      #    @driver.stop_and_save_recording_screen 'example.mp4'
      #

      # rubocop:enable Metrics/LineLength

      ####
      ## class << self
      ####

      class << self
        def extended(_mod)
          extend_webdriver_with_forwardable

          add_endpoint_method(:shake) do
            def shake
              execute :shake
            end
          end

          add_endpoint_method(:device_time) do
            def device_time
              execute :device_time
            end
          end

          add_endpoint_method(:take_element_screenshot) do
            def take_element_screenshot(element, png_path)
              result = execute :take_element_screenshot, id: element.ref

              extension = File.extname(png_path).downcase
              if extension != '.png'
                ::Appium::Logger.warn 'name used for saved screenshot does not match file type. '\
                                'It should end with .png extension'
              end
              File.open(png_path, 'wb') { |f| f << result.unpack('m')[0] }
            end
          end

          add_endpoint_method(:set_immediate_value) do
            def set_immediate_value(element, *value)
              keys = ::Selenium::WebDriver::Keys.encode(value)
              execute :set_immediate_value, { id: element.ref }, value: Array(keys)
            end
          end

          add_endpoint_method(:replace_value) do
            def replace_value(element, *value)
              keys = ::Selenium::WebDriver::Keys.encode(value)
              execute :replace_value, { id: element.ref }, value: Array(keys)
            end
          end

          add_endpoint_method(:get_settings) do
            def get_settings
              execute :get_settings, {}
            end
          end

          add_endpoint_method(:update_settings) do
            def update_settings(settings)
              execute :update_settings, {}, settings: settings
            end
          end

          add_endpoint_method(:save_viewport_screenshot) do
            def save_viewport_screenshot(png_path)
              extension = File.extname(png_path).downcase
              if extension != '.png'
                ::Appium::Logger.warn 'name used for saved screenshot does not match file type. '\
                                  'It should end with .png extension'
              end
              viewport_screenshot_encode64 = execute_script('mobile: viewportScreenshot')
              File.open(png_path, 'wb') { |f| f << viewport_screenshot_encode64.unpack('m')[0] }
            end
          end

          add_keyevent
          add_touch_actions
          add_ime_actions
          add_handling_context
          add_screen_recording
          add_app_management
          add_device_lock
          add_file_management
          add_keyboard
          Core::Device::ImageComparison.extended
        end

        # def extended

        # @private
        def add_endpoint_method(method)
          block_given? ? create_bridge_command(method, &Proc.new) : create_bridge_command(method)

          delegate_driver_method method
          delegate_from_appium_driver method
        end

        # @private CoreBridge
        def extend_webdriver_with_forwardable
          return if ::Appium::Core::Base::Driver.is_a? Forwardable
          ::Appium::Core::Base::Driver.class_eval do
            extend Forwardable
          end
        end

        # For ruby_lib compatibility
        # @private
        def delegate_from_appium_driver(method, delegation_target = :driver)
          def_delegator delegation_target, method
        end

        # @private
        def delegate_driver_method(method)
          return if ::Appium::Core::Base::Driver.method_defined? method
          ::Appium::Core::Base::Driver.class_eval { def_delegator :@bridge, method }
        end

        # @private
        def create_bridge_command(method)
          ::Appium::Core::Base::Bridge::MJSONWP.class_eval do
            block_given? ? class_eval(&Proc.new) : define_method(method) { execute method }
          end
          ::Appium::Core::Base::Bridge::W3C.class_eval do
            block_given? ? class_eval(&Proc.new) : define_method(method) { execute method }
          end
        end

        def add_device_lock
          add_endpoint_method(:lock) do
            def lock(duration = nil)
              opts = duration ? { seconds: duration } : {}
              execute :lock, {}, opts
            end
          end

          add_endpoint_method(:device_locked?) do
            def device_locked?
              execute :device_locked?
            end
          end

          add_endpoint_method(:unlock) do
            def unlock
              execute :unlock
            end
          end
        end

        def add_file_management
          add_endpoint_method(:push_file) do
            def push_file(path, filedata)
              encoded_data = Base64.encode64 filedata
              execute :push_file, {}, path: path, data: encoded_data
            end
          end

          add_endpoint_method(:pull_file) do
            def pull_file(path)
              data = execute :pull_file, {}, path: path
              Base64.decode64 data
            end
          end

          add_endpoint_method(:pull_folder) do
            def pull_folder(path)
              data = execute :pull_folder, {}, path: path
              Base64.decode64 data
            end
          end
        end

        # rubocop:disable Metrics/ParameterLists,Metrics/PerceivedComplexity,Metrics/CyclomaticComplexity
        def add_app_management
          add_endpoint_method(:launch_app) do
            def launch_app
              execute :launch_app
            end
          end

          add_endpoint_method(:close_app) do
            def close_app
              execute :close_app
            end
          end

          add_endpoint_method(:close_app) do
            def close_app
              execute :close_app
            end
          end

          add_endpoint_method(:reset) do
            def reset
              execute :reset
            end
          end

          add_endpoint_method(:app_strings) do
            def app_strings(language = nil)
              opts = language ? { language: language } : {}
              execute :app_strings, {}, opts
            end
          end

          add_endpoint_method(:background_app) do
            def background_app(duration = 0)
              execute :background_app, {}, seconds: duration
            end
          end

          add_endpoint_method(:install_app) do
            def install_app(path,
                            replace: nil,
                            timeout: nil,
                            allow_test_packages: nil,
                            use_sdcard: nil,
                            grant_permissions: nil)
              args = { appPath: path }

              args[:options] = {} unless options?(replace, timeout, allow_test_packages, use_sdcard, grant_permissions)

              args[:options][:replace] = replace unless replace.nil?
              args[:options][:timeout] = timeout unless timeout.nil?
              args[:options][:allowTestPackages] = allow_test_packages unless allow_test_packages.nil?
              args[:options][:useSdcard] = use_sdcard unless use_sdcard.nil?
              args[:options][:grantPermissions] = grant_permissions unless grant_permissions.nil?

              execute :install_app, {}, args
            end

            private

            def options?(replace, timeout, allow_test_packages, use_sdcard, grant_permissions)
              replace.nil? || timeout.nil? || allow_test_packages.nil? || use_sdcard.nil? || grant_permissions.nil?
            end
          end

          add_endpoint_method(:remove_app) do
            def remove_app(id, keep_data: nil, timeout: nil)
              # required: [['appId'], ['bundleId']]
              args = { appId: id }

              args[:options] = {} unless keep_data.nil? || timeout.nil?
              args[:options][:keepData] = keep_data unless keep_data.nil?
              args[:options][:timeout] = timeout unless timeout.nil?

              execute :remove_app, {}, args
            end
          end

          add_endpoint_method(:app_installed?) do
            def app_installed?(app_id)
              # required: [['appId'], ['bundleId']]
              execute :app_installed?, {}, bundleId: app_id
            end
          end

          add_endpoint_method(:activate_app) do
            def activate_app(app_id)
              # required: [['appId'], ['bundleId']]
              execute :activate_app, {}, bundleId: app_id
            end
          end

          add_endpoint_method(:terminate_app) do
            def terminate_app(app_id, timeout: nil)
              # required: [['appId'], ['bundleId']]
              #
              args = { appId: app_id }

              args[:options] = {} unless timeout.nil?
              args[:options][:timeout] = timeout unless timeout.nil?

              execute :terminate_app, {}, args
            end
          end

          add_endpoint_method(:app_state) do
            def app_state(app_id)
              # required: [['appId'], ['bundleId']]
              response = execute :app_state, {}, appId: app_id

              case response
              when 0, 1, 2, 3, 4
                ::Appium::Core::Device::AppState::STATUS[response]
              else
                ::Appium::Logger.debug("Unexpected status in app_state: #{response}")
                response
              end
            end
          end
        end
        # rubocop:enable Metrics/ParameterLists,Metrics/PerceivedComplexity,Metrics/CyclomaticComplexity

        def add_keyevent
          # Only for Selendroid
          add_endpoint_method(:keyevent) do
            def keyevent(key, metastate = nil)
              args             = { keycode: key }
              args[:metastate] = metastate if metastate
              execute :keyevent, {}, args
            end
          end

          add_endpoint_method(:press_keycode) do
            # TODO: change the way to set flags
            def press_keycode(key, metastate = nil, flags: nil)
              args             = { keycode: key }
              args[:metastate] = metastate if metastate
              args[:flags]     = flags if flags
              execute :press_keycode, {}, args
            end
          end

          add_endpoint_method(:long_press_keycode) do
            def long_press_keycode(key, metastate = nil, flags: nil)
              args             = { keycode: key }
              args[:metastate] = metastate if metastate
              args[:flags]     = flags if flags
              execute :long_press_keycode, {}, args
            end
          end
        end

        def add_keyboard
          add_endpoint_method(:hide_keyboard) do
            def hide_keyboard(close_key = nil, strategy = nil)
              option = {}

              option[:key] = close_key || 'Done'        # default to Done key.
              option[:strategy] = strategy || :pressKey # default to pressKey

              execute :hide_keyboard, {}, option
            end
          end

          add_endpoint_method(:is_keyboard_shown) do
            def is_keyboard_shown # rubocop:disable Naming/PredicateName for compatibility
              execute :is_keyboard_shown
            end
          end
        end

        def add_touch_actions
          add_endpoint_method(:touch_actions) do
            def touch_actions(actions)
              actions = { actions: [actions].flatten }
              execute :touch_actions, {}, actions
            end
          end

          add_endpoint_method(:multi_touch) do
            def multi_touch(actions)
              execute :multi_touch, {}, actions: actions
            end
          end
        end

        def add_ime_actions
          add_endpoint_method(:ime_activate) do
            def ime_activate(ime_name)
              # from Selenium::WebDriver::Remote::OSS
              execute :ime_activate_engine, {}, engine: ime_name
            end
          end

          add_endpoint_method(:ime_available_engines) do
            def ime_available_engines
              execute :ime_get_available_engines
            end
          end

          add_endpoint_method(:ime_active_engine) do
            # from Selenium::WebDriver::Remote::OSS
            def ime_active_engine
              execute :ime_get_active_engine
            end
          end

          add_endpoint_method(:ime_activated) do
            # from Selenium::WebDriver::Remote::OSS
            def ime_activated
              execute :ime_is_activated
            end
          end

          add_endpoint_method(:ime_deactivate) do
            # from Selenium::WebDriver::Remote::OSS
            def ime_deactivate
              execute :ime_deactivate, {}
            end
          end
        end

        def add_handling_context
          add_endpoint_method(:within_context) do
            def within_context(context)
              existing_context = current_context
              set_context context
              if block_given?
                result = yield
                set_context existing_context
                result
              else
                set_context existing_context
              end
            end
          end

          add_endpoint_method(:switch_to_default_context) do
            def switch_to_default_context
              set_context nil
            end
          end

          add_endpoint_method(:current_context) do
            def current_context
              execute :current_context
            end
          end

          add_endpoint_method(:available_contexts) do
            def available_contexts
              # return empty array instead of nil on failure
              execute(:available_contexts, {}) || []
            end
          end

          add_endpoint_method(:set_context) do
            def set_context(context = null)
              execute :set_context, {}, name: context
            end
          end
        end

        def add_screen_recording
          add_endpoint_method(:stop_recording_screen) do
            def stop_recording_screen(remote_path: nil, user: nil, pass: nil, method: 'PUT')
              option = ::Appium::Core::Device::ScreenRecord.new(
                remote_path: remote_path, user: user, pass: pass, method: method
              ).upload_option

              params = option.empty? ? {} : { options: option }

              execute(:stop_recording_screen, {}, params)
            end
          end

          add_endpoint_method(:stop_and_save_recording_screen) do
            def stop_and_save_recording_screen(file_path)
              base64data = execute(:stop_recording_screen, {}, {})
              File.open(file_path, 'wb') { |f| f << Base64.decode64(base64data) }
            end
          end
        end
      end # class << self
    end # module Device
  end # module Core
end # module Appium
