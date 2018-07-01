require_relative 'common/touch_action/touch_actions'
require_relative 'common/touch_action/multi_touch'

require_relative 'element/image'

require_relative 'device/screen_record'
require_relative 'device/app_state'
require_relative 'device/clipboard_content_type'
require_relative 'device/image_comparison'
require_relative 'device/app_management'
require_relative 'device/keyboard'
require_relative 'device/file_management'
require_relative 'device/touch_actions'
require_relative 'device/ime_actions'
require_relative 'device/context'
require_relative 'device/keyevent'
require_relative 'device/setting'
require_relative 'device/value'

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
      # @param [String] format The set of format specifiers. Read https://momentjs.com/docs/ to get the full list of supported
      #                        datetime format specifiers. The default format is `YYYY-MM-DDTHH:mm:ssZ`,
      #                        which complies to ISO-8601
      # @return [String] Formatted datetime string or the raw command output if formatting fails
      #
      # @example
      #
      #   @driver.device_time #=> "2018-06-12T11:13:31+02:00"
      #   @driver.device_time "YYYY-MM-DD" #=> "2018-06-12"
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

      # @!method press_keycode(key, metastate: [], flags: [])
      # Press keycode on the device.
      # http://developer.android.com/reference/android/view/KeyEvent.html
      # @param [Integer] key The key to press. The values which have `KEYCODE_` prefix in http://developer.android.com/reference/android/view/KeyEvent.html
      #                      e.g.: KEYCODE_HOME is `3` or `0x00000003`
      # @param [[Integer]] metastate: The state the metakeys should be in when pressing the key. Default is empty Array.
      #                            Metastate have `META_` prefix in https://developer.android.com/reference/android/view/KeyEvent.html
      #                            e.g.: META_SHIFT_ON is `1` or `0x00000001`
      # @param [[Integer]] flags: Native Android flag value. Several flags can be combined into a single key event.
      #                           Default is empty Array.  Can set multiple flags as Array.
      #                           Flags have `FLAG_` prefix in http://developer.android.com/reference/android/view/KeyEvent.html
      #                           e.g.: FLAG_CANCELED is `32` or `0x00000020`
      #
      # @example
      #
      #   @driver.press_keycode 66
      #   @driver.press_keycode 66, flags: [0x02]
      #   @driver.press_keycode 66, metastate: [1], flags: [32]
      #

      # @!method long_press_keycode(key, metastate: [], flags: [])
      # Long press keycode on the device.
      # http://developer.android.com/reference/android/view/KeyEvent.html
      # @param [Integer] key The key to long press. The values which have `KEYCODE_` prefix in http://developer.android.com/reference/android/view/KeyEvent.html
      #                      e.g.: KEYCODE_HOME is `3` or `0x00000003`
      # @param [[Integer]] metastate: The state the metakeys should be in when pressing the key. Default is empty Array.
      #                            Metastate have `META_` prefix in https://developer.android.com/reference/android/view/KeyEvent.html
      #                            e.g.: META_SHIFT_ON is `1` or `0x00000001`
      # @param [[Integer]] flags: Native Android flag value. Several flags can be combined into a single key event.
      #                           Default is empty Array. Can set multiple flags as Array.
      #                           Flags have `FLAG_` prefix in http://developer.android.com/reference/android/view/KeyEvent.html
      #                           e.g.: FLAG_CANCELED is `32` or `0x00000020`
      #
      # @example
      #
      #   @driver.long_press_keycode 66
      #   @driver.long_press_keycode 66, flags: [0x20, 0x2000]
      #   @driver.long_press_keycode 66, metastate: [1], flags: [32, 8192]
      #

      # @!method push_file(path, filedata)
      # Place a file in a specific location on the device.
      # On iOS, the server should have ifuse libraries installed and configured properly for this feature to work on real devices.
      # On Android, the application under test should be built with debuggable flag enabled in order to get access to
      # its container on the internal file system.
      #
      # @see https://github.com/libimobiledevice/ifuse iFuse GitHub page6
      # @see https://github.com/osxfuse/osxfuse/wiki/FAQ osxFuse FAQ
      # @see https://developer.android.com/studio/debug/ 'Debug Your App' developer article
      #
      # @param [String] path The absolute path on the device to store data at.
      #                      If the path starts with application id prefix, then the file will be pushed to
      #                      the root of the corresponding application container.

      # @param [String] path Either an absolute path OR, for iOS devices, a path relative to the app, as described.
      #                      If the path starts with application id prefix, then the file will be pushed to the root of
      #                      the corresponding application container.
      # @param [String] filedata Raw file data to be sent to the device. Converted to base64 in the method.
      #
      # @example
      #
      #   @driver.push_file "/file/to/path", "data"
      #

      # @!method pull_file(path)
      # Pull a file from the simulator/device.
      # On iOS the server should have ifuse
      # libraries installed and configured properly for this feature to work on real devices.
      # On Android the application under test should be built with debuggable flag enabled in order to get access
      # to its container on the internal file system.
      #
      # @see https://github.com/libimobiledevice/ifuse iFuse GitHub page6
      # @see https://github.com/osxfuse/osxfuse/wiki/FAQ osxFuse FAQ
      # @see https://developer.android.com/studio/debug/ 'Debug Your App' developer article
      #
      # @param [String] path Either an absolute path OR, for iOS devices, a path relative to the app, as described.
      #                      If the path starts with application id prefix, then the file will be pulled from the root
      #                      of the corresponding application container.
      #                      Otherwise the root folder is considered as / on Android and on iOS it is a media folder root
      #                      (real devices only).
      # @return [Base64-decoded] Base64 decoded data
      #
      # @example
      #
      #   @driver.pull_file '/local/data/some/path'     #=> Get the file at that path
      #   @driver.pull_file 'Shenanigans.app/some/file' #=> Get 'some/file' from the install location of Shenanigans.app
      #

      # @!method pull_folder(path)
      # Pull a folder content from the simulator/device.
      # On iOS the server should have ifuse libraries installed and configured properly for this feature to work on real devices.
      # On Android the application under test should be built with debuggable flag enabled in order to get access to its container
      # on the internal file system.
      #
      # @see https://github.com/libimobiledevice/ifuse iFuse GitHub page6
      # @see https://github.com/osxfuse/osxfuse/wiki/FAQ osxFuse FAQ
      # @see https://developer.android.com/studio/debug/ 'Debug Your App' developer article
      #
      # @param [String] path Absolute path to the folder.
      #                      If the path starts with <em>@applicationId/</em> prefix, then the folder will be pulled
      #                      from the root of the corresponding application container.
      #                      Otherwise the root folder is considered as / on Android and on iOS it is a media folder root
      #                      (real devices only).
      #
      # @return [Base64-decoded] Base64 decoded data which is zip archived
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
            def device_time(format = nil)
              arg = {}
              arg[:format] = format unless format.nil?
              execute :device_time, {}, arg
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

          Value.add_methods
          Setting.add_methods
          KeyEvent.add_methods
          Context.add_methods
          ImeActions.add_methods
          TouchActions.add_methods
          FileManagement.add_methods
          Keyboard.add_methods
          AppManagement.add_methods
          ScreenRecord.add_methods
          ImageComparison.add_methods
          AppState.add_methods

          # Compatibility for appium_lib
          # TODO: Will remove
          [:take_element_screenshot, :lock, :device_locked?, :unlock].each do |key|
            delegate_from_appium_driver key
          end
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
      end # class << self
    end
  end # module Core
end # module Appium
