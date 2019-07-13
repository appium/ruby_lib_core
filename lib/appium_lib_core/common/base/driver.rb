# frozen_string_literal: true

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'base64'
require_relative 'search_context'
require_relative 'screenshot'

module Appium
  module Core
    class Base
      class Driver < ::Selenium::WebDriver::Driver
        include ::Selenium::WebDriver::DriverExtensions::UploadsFiles
        include ::Selenium::WebDriver::DriverExtensions::HasSessionId
        include ::Selenium::WebDriver::DriverExtensions::Rotatable
        include ::Selenium::WebDriver::DriverExtensions::HasRemoteStatus
        include ::Selenium::WebDriver::DriverExtensions::HasWebStorage

        include ::Appium::Core::Base::SearchContext
        include ::Appium::Core::Base::TakeScreenshot

        def initialize(opts = {})
          listener = opts.delete(:listener)
          @bridge = ::Appium::Core::Base::Bridge.handshake(opts)
          if @bridge.dialect == :oss # MJSONWP
            extend ::Selenium::WebDriver::DriverExtensions::HasTouchScreen
            extend ::Selenium::WebDriver::DriverExtensions::HasLocation
            extend ::Selenium::WebDriver::DriverExtensions::HasNetworkConnection
          elsif @bridge.dialect == :w3c
            # TODO: Only for Appium. Ideally, we'd like to remove the below like selenium-webdriver
            extend ::Selenium::WebDriver::DriverExtensions::HasTouchScreen
            extend ::Selenium::WebDriver::DriverExtensions::HasLocation
            extend ::Selenium::WebDriver::DriverExtensions::HasNetworkConnection
          end
          super(@bridge, listener: listener)
        end

        # Get the dialect value
        # @return [:oss|:w3c]
        def dialect
          @bridge.dialect
        end

        # Update +server_url+ and HTTP clients following this arguments, protocol, host, port and path.
        # After this method, +@bridge.http+ will be a new instance following them instead of +server_url+ which is
        # set before creating session.
        #
        # @example
        #
        #     driver = core.start_driver server_url: 'http://example1.com:8000/wd/hub # @bridge.http is for 'http://example1.com:8000/wd/hub/'
        #     driver.update_sending_request_to protocol: 'https', host: 'example2.com', port: 9000, path: '/wd/hub'
        #     driver.manage.timeouts.implicit_wait = 10 # @bridge.http is for 'https://example2.com:9000/wd/hub/'
        #
        def update_sending_request_to(protocol:, host:, port:, path:)
          @bridge.http.update_sending_request_to(scheme: protocol,
                                                 host: host,
                                                 port: port,
                                                 path: path)
        end

        ### Methods for Appium

        # Lock the device
        # @return [String]
        #
        # @example
        #
        #   @driver.lock    #=> Lock the device
        #   @driver.lock(5) #=> Lock the device in 5 sec and unlock the device after 5 sec.
        #                   #   Block other commands during locking the device.
        #
        def lock(duration = nil)
          @bridge.lock(duration)
        end

        # Check current device status is weather locked or not
        #
        # @example
        #
        #   @driver.device_locked?
        #   @driver.locked?
        #
        def locked?
          @bridge.device_locked?
        end
        alias device_locked? locked?

        # Unlock the device
        #
        # @example
        #
        #   @driver.unlock
        #
        def unlock
          @bridge.unlock
        end

        # Hide the onscreen keyboard
        # @param [String] close_key The name of the key which closes the keyboard.
        #   Defaults to 'Done' for iOS(except for XCUITest).
        # @param [Symbol] strategy The symbol of the strategy which closes the keyboard.
        #   XCUITest ignore this argument.
        #   Default for iOS is +:pressKey+. Default for Android is +:tapOutside+.
        #
        # @example
        #
        #   @driver.hide_keyboard # Close a keyboard with the 'Done' button
        #   @driver.hide_keyboard('Finished') # Close a keyboard with the 'Finished' button
        #   @driver.hide_keyboard(nil, :tapOutside) # Close a keyboard with tapping out side of keyboard
        #
        def hide_keyboard(close_key = nil, strategy = nil)
          @bridge.hide_keyboard close_key, strategy
        end

        # Get whether keyboard is displayed or not.
        # @return [Boolean] Return true if keyboard is shown. Return false if keyboard is hidden.
        #
        # @example
        #   @driver.is_keyboard_shown # false
        #   @driver.keyboard_shown?   # true
        #
        def keyboard_shown?
          @bridge.is_keyboard_shown
        end
        alias is_keyboard_shown keyboard_shown?

        # [DEPRECATION]
        # Send keys for a current active element
        # @param [String] key Input text
        #
        # @example
        #
        #   @driver.send_keys 'happy testing!'
        #
        def send_keys(*key)
          ::Appium::Logger.warn(
            '[DEPRECATION] Driver#send_keys is deprecated in W3C spec. Use driver.action.<command>.perform instead'
          )
          @bridge.send_keys_to_active_element(key)
        end
        alias type send_keys

        class DriverSettings
          # @private this class is private
          def initialize(bridge)
            @bridge = bridge
          end

          def get
            @bridge.get_settings
          end

          def update(settings)
            @bridge.update_settings(settings)
          end
        end
        private_constant :DriverSettings

        # Returns an instance of DriverSettings to call get/update.
        #
        # @example
        #
        #   @driver.settings.get
        #   @driver.settings.update('allowInvisibleElements': true)
        #
        def settings
          @driver_settings ||= DriverSettings.new(@bridge) # rubocop:disable Naming/MemoizedInstanceVariableName
        end

        # Get appium Settings for current test session.
        # Alias of @driver.settings.get
        #
        # @example
        #
        #   @driver.get_settings
        #   @driver.settings.get
        #
        def get_settings
          settings.get
        end

        # Update Appium Settings for current test session
        # Alias of @driver.settings#update
        #
        # @param [Hash] value Settings to update, keys are settings, values to value to set each setting to
        #
        # @example
        #
        #   @driver.update_settings('allowInvisibleElements': true)
        #   @driver.settings.update('allowInvisibleElements': true)
        #   @driver.settings = { 'allowInvisibleElements': true }
        #
        def settings=(value)
          settings.update(value)
        end
        alias update_settings settings=

        class DeviceIME
          # @private this class is private
          def initialize(bridge)
            @bridge = bridge
          end

          def activate(ime_name)
            @bridge.ime_activate(ime_name)
          end

          def available_engines
            @bridge.ime_available_engines
          end

          def active_engine
            @bridge.ime_active_engine
          end

          def activated?
            @bridge.ime_activated
          end

          def deactivate
            @bridge.ime_deactivate
          end
        end
        private_constant :DeviceIME

        # Returns an instance of DeviceIME
        #
        # @example
        #
        #   @driver.ime.activate engine: 'com.android.inputmethod.latin/.LatinIME'
        #   @driver.ime.available_engines #=> Get the list of IME installed in the target device
        #   @driver.ime.active_engine #=> Get the current active IME such as 'com.android.inputmethod.latin/.LatinIME'
        #   @driver.ime.activated #=> True if IME is activated
        #   @driver.ime.deactivate #=> Deactivate current IME engine
        #
        def ime
          @device_ime ||= DeviceIME.new(@bridge) # rubocop:disable Naming/MemoizedInstanceVariableName
        end

        # Android only. Make an engine that is available active.
        #
        # @param [String] ime_name The IME owning the activity [required]
        #
        # @example
        #
        #   @driver.ime_activate engine: 'com.android.inputmethod.latin/.LatinIME'
        #   @driver.ime.activate engine: 'com.android.inputmethod.latin/.LatinIME'
        #
        def ime_activate(ime_name)
          ime.activate(ime_name)
        end

        # Android only. List all available input engines on the machine.
        #
        # @example
        #
        #   @driver.ime_available_engines #=> Get the list of IME installed in the target device
        #   @driver.ime.available_engines #=> Get the list of IME installed in the target device
        #
        def ime_available_engines
          ime.available_engines
        end

        # Android only. Get the name of the active IME engine.
        #
        # @example
        #
        #   @driver.ime_active_engine #=> Get the current active IME such as 'com.android.inputmethod.latin/.LatinIME'
        #   @driver.ime.active_engine #=> Get the current active IME such as 'com.android.inputmethod.latin/.LatinIME'
        #
        def ime_active_engine
          ime.active_engine
        end

        # @!method ime_activated
        #   Android only. Indicates whether IME input is active at the moment (not if it is available).
        #
        # @example
        #
        #   @driver.ime_activated #=> True if IME is activated
        #   @driver.ime.activated #=> True if IME is activated
        #
        def ime_activated
          ime.activated?
        end

        # Android only. De-activates the currently-active IME engine.
        #
        # @example
        #
        #   @driver.ime_deactivate #=> Deactivate current IME engine
        #   @driver.ime.deactivate #=> Deactivate current IME engine
        #
        def ime_deactivate
          ime.deactivate
        end

        # Perform a block within the given context, then switch back to the starting context.
        # @param [String] context The context to switch to for the duration of the block.
        #
        # @example
        #
        #   result = @driver.within_context('NATIVE_APP') do
        #     @driver.find_element :tag, "button"
        #   end # The result of 'find_element :tag, "button"'
        #
        def within_context(context)
          block_given? ? @bridge.within_context(context, &Proc.new) : @bridge.within_context(context)
        end

        # Change to the default context. This is equivalent to +set_context nil+.
        #
        # @example
        #
        #   @driver.switch_to_default_context
        #
        def switch_to_default_context
          @bridge.switch_to_default_context
        end

        # @return [String] The context currently being used.
        #
        # @example
        #
        #   @driver.current_context
        #
        def current_context
          @bridge.current_context
        end

        # @return [Array<String>] All usable contexts, as an array of strings.
        #
        # @example
        #
        #   @driver.available_contexts
        #
        def available_contexts
          @bridge.available_contexts
        end

        # Change the context to the given context.
        # @param [String] context The context to change to
        #
        # @example
        #
        #   @driver.set_context "NATIVE_APP"
        #   @driver.context = "NATIVE_APP"
        #
        def context=(context = null)
          @bridge.set_context(context)
        end
        alias set_context context=

        # Set the value to element directly
        #
        # @example
        #
        #   @driver.set_immediate_value element, 'hello'
        #
        def set_immediate_value(element, *value)
          ::Appium::Logger.warn '[DEPRECATION] driver#set_immediate_value(element, *value) is deprecated. ' \
            'Use Element#immediate_value(*value) instead'
          @bridge.set_immediate_value(element, *value)
        end

        # Replace the value to element directly
        #
        # @example
        #
        #   @driver.replace_value element, 'hello'
        #
        def replace_value(element, *value)
          ::Appium::Logger.warn '[DEPRECATION] driver#replace_value(element, *value) is deprecated. ' \
            'Use Element#replace_value(*value) instead'
          @bridge.replace_value(element, *value)
        end

        # Place a file in a specific location on the device.
        # On iOS, the server should have ifuse libraries installed and configured properly for this feature to work on
        # real devices.
        # On Android, the application under test should be built with debuggable flag enabled in order to get access to
        # its container on the internal file system.
        #
        # {https://github.com/libimobiledevice/ifuse iFuse GitHub page6}
        #
        # {https://github.com/osxfuse/osxfuse/wiki/FAQ osxFuse FAQ}
        #
        # {https://developer.android.com/studio/debug 'Debug Your App' developer article}
        #
        # @param [String] path Either an absolute path OR, for iOS devices, a path relative to the app, as described.
        #                      If the path starts with application id prefix, then the file will be pushed to the root of
        #                      the corresponding application container.
        # @param [String] filedata Raw file data to be sent to the device. Converted to base64 in the method.
        #
        # @example
        #
        #   @driver.push_file "/file/to/path", "data"
        #
        #   file = File.read "your/path/to/test_image.png"
        #   @driver.push_file "/sdcard/Pictures", file # Push a file binary to /sdcard/Pictures path in Android
        #
        def push_file(path, filedata)
          @bridge.push_file(path, filedata)
        end

        # Pull a file from the simulator/device.
        # On iOS the server should have ifuse
        # libraries installed and configured properly for this feature to work on real devices.
        # On Android the application under test should be built with debuggable flag enabled in order to get access
        # to its container on the internal file system.
        #
        # {https://github.com/libimobiledevice/ifuse iFuse GitHub page6}
        #
        # {https://github.com/osxfuse/osxfuse/wiki/FAQ osxFuse FAQ}
        #
        # {https://developer.android.com/studio/debug 'Debug Your App' developer article}
        #
        # @param [String] path Either an absolute path OR, for iOS devices, a path relative to the app, as described.
        #                      If the path starts with application id prefix, then the file will be pulled from the root
        #                      of the corresponding application container.
        #                      Otherwise the root folder is considered as / on Android and on iOS it is a media folder root
        #                      (real devices only).
        #                      Only pulling files from application containers is supported for iOS Simulator.
        #                      Provide the remote path in format
        #                      <code>@bundle.identifier:container_type/relative_path_in_container</code>
        #                      (Make sure this in ifuse doc)
        #
        # @return [Base64-decoded] Base64 decoded data
        #
        # @example
        #
        #   decoded_file = @driver.pull_file '/local/data/some/path'     #=> Get the file at that path
        #   decoded_file = @driver.pull_file 'Shenanigans.app/some/file'
        #                  #=> Get 'some/file' from the install location of Shenanigans.app
        #   decoded_file = @driver.pull_file '@com.appium.example/Documents/file.txt'
        #                  #=> Get 'file.txt' in @com.appium.example/Documents
        #   File.open('proper_filename', 'wb') { |f| f<< decoded_file }
        #
        def pull_file(path)
          @bridge.pull_file(path)
        end

        # Pull a folder content from the simulator/device.
        # On iOS the server should have ifuse libraries installed and configured properly for this feature to work
        # on real devices.
        # On Android the application under test should be built with debuggable flag enabled in order to get access to
        # its container on the internal file system.
        #
        # {https://github.com/libimobiledevice/ifuse iFuse GitHub page6}
        #
        # {https://github.com/osxfuse/osxfuse/wiki/FAQ osxFuse FAQ}
        #
        # {https://developer.android.com/studio/debug 'Debug Your App' developer article}
        #
        # @param [String] path Absolute path to the folder.
        #                      If the path starts with <em>@applicationId/</em> prefix, then the folder will be pulled
        #                      from the root of the corresponding application container.
        #                      Otherwise the root folder is considered as / on Android and on iOS it is a media folder root
        #                      (real devices only).
        #                      Only pulling files from application containers is supported for iOS Simulator.
        #                      Provide the remote path in format
        #                      <code>@bundle.identifier:container_type/relative_path_in_container</code>
        #                      (Make sure this in ifuse doc)
        #
        # @return [Base64-decoded] Base64 decoded data which is zip archived
        #
        # @example
        #
        #   decoded_file = @driver.pull_folder '/data/local/tmp' #=> Get the folder at that path
        #   decoded_file = @driver.pull_file '@com.appium.example/Documents' #=> Get 'Documents' in @com.appium.example
        #   File.open('proper_filename', 'wb') { |f| f<< decoded_file }
        #
        def pull_folder(path)
          @bridge.pull_folder(path)
        end

        # Send keyevent on the device.(Only for Selendroid)
        # http://developer.android.com/reference/android/view/KeyEvent.html
        # @param [integer] key The key to press.
        # @param [String] metastate The state the metakeys should be in when pressing the key.
        #
        # @example
        #
        #   @driver.keyevent 82
        #
        def keyevent(key, metastate = nil)
          @bridge.keyevent(key, metastate)
        end

        # Press keycode on the device.
        # http://developer.android.com/reference/android/view/KeyEvent.html
        # @param [Integer] key The key to press. The values which have +KEYCODE_+ prefix in http://developer.android.com/reference/android/view/KeyEvent.html
        #                      e.g.: KEYCODE_HOME is +3+ or +0x00000003+
        # @param [[Integer]] metastate The state the metakeys should be in when pressing the key. Default is empty Array.
        #                              Metastate have +META_+ prefix in https://developer.android.com/reference/android/view/KeyEvent.html
        #                              e.g.: META_SHIFT_ON is +1+ or +0x00000001+
        # @param [[Integer]] flags Native Android flag value. Several flags can be combined into a single key event.
        #                          Default is empty Array.  Can set multiple flags as Array.
        #                          Flags have +FLAG_+ prefix in http://developer.android.com/reference/android/view/KeyEvent.html
        #                          e.g.: FLAG_CANCELED is +32+ or +0x00000020+
        #
        # @example
        #
        #   @driver.press_keycode 66
        #   @driver.press_keycode 66, flags: [0x02]
        #   @driver.press_keycode 66, metastate: [1], flags: [32]
        #
        def press_keycode(key, metastate: [], flags: [])
          @bridge.press_keycode(key, metastate: metastate, flags: flags)
        end

        # Long press keycode on the device.
        # http://developer.android.com/reference/android/view/KeyEvent.html
        # @param [Integer] key The key to long press. The values which have +KEYCODE_+ prefix in http://developer.android.com/reference/android/view/KeyEvent.html
        #                      e.g.: KEYCODE_HOME is +3+ or +0x00000003+
        # @param [[Integer]] metastate The state the metakeys should be in when pressing the key. Default is empty Array.
        #                              Metastate have +META_+ prefix in https://developer.android.com/reference/android/view/KeyEvent.html
        #                              e.g.: META_SHIFT_ON is +1+ or +0x00000001+
        # @param [[Integer]] flags Native Android flag value. Several flags can be combined into a single key event.
        #                          Default is empty Array. Can set multiple flags as Array.
        #                          Flags have +FLAG_+ prefix in http://developer.android.com/reference/android/view/KeyEvent.html
        #                          e.g.: FLAG_CANCELED is +32+ or +0x00000020+
        #
        # @example
        #
        #   @driver.long_press_keycode 66
        #   @driver.long_press_keycode 66, flags: [0x20, 0x2000]
        #   @driver.long_press_keycode 66, metastate: [1], flags: [32, 8192]
        #
        def long_press_keycode(key, metastate: [], flags: [])
          @bridge.long_press_keycode(key, metastate: metastate, flags: flags)
        end

        # Start the simulator and application configured with desired capabilities
        #
        # @example
        #
        #   @driver.launch_app
        #
        def launch_app
          @bridge.launch_app
        end

        # Close an app on device
        #
        # @example
        #
        #   @driver.close_app
        #
        def close_app
          @bridge.close_app
        end

        # Reset the device, relaunching the application.
        #
        # @example
        #
        #   @driver.reset
        #
        def reset
          @bridge.reset
        end

        # Return the hash of all localization strings.
        # @return [Hash]
        #
        # @example
        #
        #   @driver.app_strings #=> "TransitionsTitle"=>"Transitions", "WebTitle"=>"Web"
        #
        def app_strings(language = nil)
          @bridge.app_strings(language)
        end

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
        def background_app(duration = 0)
          @bridge.background_app(duration)
        end

        # Install the given app onto the device
        #
        # @param [String] path The absolute local path or remote http URL to an .ipa or .apk file,
        #                      or a .zip containing one of these.
        # @param [Boolean] replace Only for Android. Whether to reinstall/upgrade the package if it is already present
        #                          on the device under test. +true+ by default
        # @param [Integer] timeout Only for Android. How much time to wait for the installation to complete.
        #                          60000ms by default.
        # @param [Boolean] allow_test_packages Only for Android. Whether to allow installation of packages marked as test
        #                                      in the manifest. +false+ by default
        # @param [Boolean] use_sdcard Only for Android. Whether to use the SD card to install the app. +false+ by default
        # @param [Boolean] grant_permissions Only for Android. whether to automatically grant application permissions
        #                                    on Android 6+ after the installation completes. +false+ by default
        #
        # @example
        #
        #   @driver.install_app("/path/to/test.apk")
        #   @driver.install_app("/path/to/test.apk", replace: true, timeout: 20000, allow_test_packages: true,
        #                       use_sdcard: false, grant_permissions: false)
        #
        def install_app(path,
                        replace: nil,
                        timeout: nil,
                        allow_test_packages: nil,
                        use_sdcard: nil,
                        grant_permissions: nil)
          @bridge.install_app(path,
                              replace: replace,
                              timeout: timeout,
                              allow_test_packages: allow_test_packages,
                              use_sdcard: use_sdcard,
                              grant_permissions: grant_permissions)
        end

        # @param [Strong] app_id BundleId for iOS or package name for Android
        # @param [Boolean] keep_data Only for Android. Whether to keep application data and caches after it is uninstalled.
        #                             +false+ by default
        # @param [Integer] timeout Only for Android. How much time to wait for the uninstall to complete. 20000ms by default.
        #
        # @example
        #
        #   @driver.remove_app("io.appium.bundle")
        #   @driver.remove_app("io.appium.bundle", keep_data: false, timeout, 10000)
        #
        def remove_app(app_id, keep_data: nil, timeout: nil)
          @bridge.remove_app(app_id, keep_data: keep_data, timeout: timeout)
        end

        # Check whether the specified app is installed on the device
        # @return [Boolean]
        #
        # @example
        #
        #   @driver.app_installed?("io.appium.bundle")
        #
        def app_installed?(app_id)
          @bridge.app_installed?(app_id)
        end

        # Activate(Launch) the specified app.
        # @return [Hash]
        #
        # @example
        #
        #   @driver.activate_app("io.appium.bundle") #=> {}
        #
        def activate_app(app_id)
          @bridge.activate_app(app_id)
        end

        # Terminate the specified app.
        #
        # @param [Strong] app_id BundleId for iOS or package name for Android
        # @param [Integer] timeout Only for Android. How much time to wait for the application termination to complete.
        #                          500ms by default.
        # @return [Boolean]
        #
        # @example
        #
        #   @driver.terminate_app("io.appium.bundle") # true
        #   @driver.terminate_app("io.appium.bundle", timeout: 500)
        #
        def terminate_app(app_id, timeout: nil)
          @bridge.terminate_app(app_id, timeout: timeout)
        end

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
        # @param [String] app_id A target app's bundle id
        # @return [AppState::STATUS] A number of the state
        #
        # @example
        #
        #      @driver.app_state("io.appium.bundle") #=> :not_running
        #      # Compatibility for other clients
        #      @driver.query_app_state("io.appium.bundle") #=> :not_running
        #
        def app_state(app_id)
          @bridge.app_state(app_id)
        end
        alias query_app_state app_state

        # @param [String] remote_path The path to the remote location, where the resulting video should be uploaded.
        #                             The following protocols are supported: http/https, ftp.
        #                             Null or empty string value (the default setting) means the content of resulting
        #                             file should be encoded as Base64 and passed as the endpoint response value.
        #                             An exception will be thrown if the generated media file is too big to
        #                             fit into the available process memory.
        # @param [String] user The name of the user for the remote authentication.
        # @param [String] pass The password for the remote authentication.
        # @param [String] method The http multipart upload method name. The 'PUT' one is used by default.
        #
        # @example
        #
        #    @driver.stop_recording_screen
        #    @driver.stop_recording_screen remote_path: 'https://example.com', user: 'example', pass: 'pass', method: 'POST'
        #
        def stop_recording_screen(remote_path: nil, user: nil, pass: nil, method: 'PUT')
          @bridge.stop_recording_screen(remote_path: remote_path, user: user, pass: pass, method: method)
        end

        # @param [String] file_path The path to save video decoded from base64 from Appium server.
        #
        # @example
        #
        #    # iOS
        #    @driver.start_recording_screen video_type: 'libx264'
        #    @driver.stop_and_save_recording_screen 'example.mp4' # Video type 'libx264' can be play as '.mp4' video
        #
        #    # Android
        #    @driver.start_recording_screen
        #    @driver.stop_and_save_recording_screen 'example.mp4'
        #
        def stop_and_save_recording_screen(file_path)
          @bridge.stop_and_save_recording_screen(file_path)
        end

        # Cause the device to shake
        #
        # @example
        #
        #   @driver.shake
        #
        def shake
          @bridge.shake
        end

        # Get the time on the device
        #
        # @param [String] format The set of format specifiers. Read https://momentjs.com/docs/ to get
        #                        the full list of supported datetime format specifiers.
        #                        The default format is +YYYY-MM-DDTHH:mm:ssZ+, which complies to ISO-8601
        # @return [String] Formatted datetime string or the raw command output if formatting fails
        #
        # @example
        #
        #   @driver.device_time #=> "2018-06-12T11:13:31+02:00"
        #   @driver.device_time "YYYY-MM-DD" #=> "2018-06-12"
        #
        def device_time(format = nil)
          @bridge.device_time(format)
        end

        # touch actions
        def touch_actions(actions)
          @bridge.touch_actions(actions)
        end

        def multi_touch(actions)
          @bridge.multi_touch(actions)
        end

        #
        # Send multiple W3C action chains to server. Use +@driver.action+ for single action chain.
        #
        # @param [Array] data Array of actions
        # @return nil|error
        #
        # @example: Zoom
        #
        #    f1 = @driver.action.add_pointer_input(:touch, 'finger1')
        #    f1.create_pointer_move(duration: 1, x: 200, y: 500,
        #                           origin: ::Selenium::WebDriver::Interactions::PointerMove::VIEWPORT)
        #    f1.create_pointer_down(:left)
        #    f1.create_pointer_move(duration: 1, x: 200, y: 200,
        #                           origin: ::Selenium::WebDriver::Interactions::PointerMove::VIEWPORT)
        #    f1.create_pointer_up(:left)
        #
        #    f2 = @driver.action.add_pointer_input(:touch, 'finger2')
        #    f2.create_pointer_move(duration: 1, x: 200, y: 500,
        #                           origin: ::Selenium::WebDriver::Interactions::PointerMove::VIEWPORT)
        #    f2.create_pointer_down(:left)
        #    f2.create_pointer_move(duration: 1, x: 200, y: 800,
        #                           origin: ::Selenium::WebDriver::Interactions::PointerMove::VIEWPORT)
        #    f2.create_pointer_up(:left)
        #
        #    @driver.perform_actions [f1, f2] #=> 'nil' if the action succeed
        #
        def perform_actions(data)
          raise ArgumentError, "'#{data}' must be Array" unless data.is_a? Array

          @bridge.send_actions data.map(&:encode).compact
          data.each(&:clear_actions)
          nil
        end

        # Get the device window's size.
        # @return [Selenium::WebDriver::Dimension]
        #
        # @example
        #   size = @driver.window_size
        #   size.width #=> Integer
        #   size.height #=> Integer
        #
        def window_size
          manage.window.size
        end

        # Get the device window's rect.
        # @return [Selenium::WebDriver::Rectangle]
        #
        # @example
        #   size = @driver.window_rect
        #   size.width #=> Integer
        #   size.height #=> Integer
        #   size.x #=> 0
        #   size.y #=> 0
        #
        def window_rect
          manage.window.rect
        end

        # Get the device window's size.
        # @return [String]
        #
        # @example
        #   @driver.back # back to the previous view
        #
        def back
          navigate.back
        end

        # Get the device window's logs.
        # @return [String]
        #
        # @example
        #
        #   @driver.logs.available_types # [:syslog, :crashlog, :performance]
        #   @driver.logs.get :syslog # []
        #
        def logs
          @logs ||= Logs.new(@bridge)
        end

        # For W3C.
        # Get the timeout related settings on the server side.
        #
        # @return [Hash]
        #
        # @example
        #   @driver.get_timeouts
        #
        def get_timeouts
          @bridge.get_timeouts
        end

        # Retrieve the capabilities of the specified session.
        # It's almost same as +@driver.capabilities+ but you can get more details.
        #
        # @return [Selenium::WebDriver::Remote::Capabilities]
        #
        # @example
        #   @driver.session_capabilities
        #
        #   #=> uiautomator2
        #   # <Selenium::WebDriver::Remote::W3C::Capabilities:0x007fa38dae1360
        #   # @capabilities=
        #   #     {:proxy=>nil,
        #   #      :browser_name=>nil,
        #   #      :browser_version=>nil,
        #   #      :platform_name=>"android",
        #   #      :page_load_strategy=>nil,
        #   #      :remote_session_id=>nil,
        #   #      :accessibility_checks=>nil,
        #   #      :profile=>nil,
        #   #      :rotatable=>nil,
        #   #      :device=>nil,
        #   #      "platform"=>"LINUX",
        #   #      "webStorageEnabled"=>false,
        #   #      "takesScreenshot"=>true,
        #   #      "javascriptEnabled"=>true,
        #   #      "databaseEnabled"=>false,
        #   #      "networkConnectionEnabled"=>true,
        #   #      "locationContextEnabled"=>false,
        #   #      "warnings"=>{},
        #   #      "desired"=>
        #   #          {"platformName"=>"android",
        #   #           "automationName"=>"uiautomator2",
        #   #           "app"=>"/path/to/app/api.apk.zip",
        #   #           "platformVersion"=>"8.1.0",
        #   #           "deviceName"=>"Android Emulator",
        #   #           "appPackage"=>"io.appium.android.apis",
        #   #           "appActivity"=>"io.appium.android.apis.ApiDemos",
        #   #           "someCapability"=>"some_capability",
        #   #           "unicodeKeyboard"=>true,
        #   #           "resetKeyboard"=>true},
        #   #      "automationName"=>"uiautomator2",
        #   #      "app"=>"/path/to/app/api.apk.zip",
        #   #      "platformVersion"=>"8.1.0",
        #   #      "deviceName"=>"emulator-5554",
        #   #      "appPackage"=>"io.appium.android.apis",
        #   #      "appActivity"=>"io.appium.android.apis.ApiDemos",
        #   #      "someCapability"=>"some_capability",
        #   #      "unicodeKeyboard"=>true,
        #   #      "resetKeyboard"=>true,
        #   #      "deviceUDID"=>"emulator-5554",
        #   #      "deviceScreenSize"=>"1080x1920",
        #   #      "deviceScreenDensity"=>420,
        #   #      "deviceModel"=>"Android SDK built for x86",
        #   #      "deviceManufacturer"=>"Google",
        #   #      "pixelRatio"=>2.625,
        #   #      "statBarHeight"=>63,
        #   #      "viewportRect"=>{"left"=>0, "top"=>63, "width"=>1080, "height"=>1731}}>
        #   #
        #   #=> XCUITest
        #   # <Selenium::WebDriver::Remote::W3C::Capabilities:0x007fb15dc01370
        #   # @capabilities=
        #   #     {:proxy=>nil,
        #   #      :browser_name=>"UICatalog",
        #   #      :browser_version=>nil,
        #   #      :platform_name=>"ios",
        #   #      :page_load_strategy=>nil,
        #   #      :remote_session_id=>nil,
        #   #      :accessibility_checks=>nil,
        #   #      :profile=>nil,
        #   #      :rotatable=>nil,
        #   #      :device=>"iphone",
        #   #      "udid"=>"DED4DBAD-8E5E-4AD6-BDC4-E75CF9AD84D8",
        #   #      "automationName"=>"XCUITest",
        #   #      "app"=>"/path/to/app/UICatalog.app",
        #   #      "platformVersion"=>"11.4",
        #   #      "deviceName"=>"iPhone Simulator",
        #   #      "useNewWDA"=>true,
        #   #      "useJSONSource"=>true,
        #   #      "someCapability"=>"some_capability",
        #   #      "sdkVersion"=>"11.4",
        #   #      "CFBundleIdentifier"=>"com.example.apple-samplecode.UICatalog",
        #   #      "pixelRatio"=>2,
        #   #      "statBarHeight"=>23.4375,
        #   #      "viewportRect"=>{"left"=>0, "top"=>47, "width"=>750, "height"=>1287}}>
        #
        def session_capabilities
          @bridge.session_capabilities
        end

        # Returns available sessions on the Appium server
        #
        # @return [[Hash]]
        #
        # @example
        #
        #   @driver.sessions #=> [{'id' => 'c363add8-a7ca-4455-b9e3-9ac4d69e95b3', 'capabilities' => { capabilities as Hash }}]
        #
        def sessions
          @bridge.sessions
        end

        # Image Comparison
        def match_images_features(first_image:,
                                  second_image:,
                                  detector_name: 'ORB',
                                  match_func: 'BruteForce',
                                  good_matches_factor: nil,
                                  visualize: false)
          @bridge.match_images_features(first_image: first_image,
                                        second_image: second_image,
                                        detector_name: detector_name,
                                        match_func: match_func,
                                        good_matches_factor: good_matches_factor,
                                        visualize: visualize)
        end

        def find_image_occurrence(full_image:, partial_image:, visualize: false, threshold: nil)
          @bridge.find_image_occurrence(full_image: full_image,
                                        partial_image: partial_image,
                                        visualize: visualize,
                                        threshold: threshold)
        end

        def get_images_similarity(first_image:, second_image:, visualize: false)
          @bridge.get_images_similarity(first_image: first_image, second_image: second_image, visualize: visualize)
        end

        def compare_images(mode: :matchFeatures, first_image:, second_image:, options: nil)
          @bridge.compare_images(mode: mode, first_image: first_image, second_image: second_image, options: options)
        end

        # @since Appium 1.8.2
        # Return an element if current view has a partial image. The logic depends on template matching by OpenCV.
        # {https://github.com/appium/appium/blob/master/docs/en/writing-running-appium/image-comparison.md image-comparison}
        #
        # You can handle settings for the comparision following below.
        # {https://github.com/appium/appium-base-driver/blob/master/lib/basedriver/device-settings.js#L6 device-settings}
        #
        # @param [String] img_path A path to a partial image you'd like to find
        #
        # @return [::Selenium::WebDriver::Element]
        #
        # @example
        #
        #     @@driver.update_settings({ fixImageFindScreenshotDims: false, fixImageTemplateSize: true,
        #                                autoUpdateImageElementPosition: true })
        #     e = @@driver.find_element_by_image './test/functional/data/test_element_image.png'
        #
        def find_element_by_image(img_path)
          template = Base64.strict_encode64 File.read img_path
          find_element :image, template
        end

        # @since Appium 1.8.2
        # Return elements if current view has a partial image. The logic depends on template matching by OpenCV.
        # {https://github.com/appium/appium/blob/master/docs/en/writing-running-appium/image-comparison.md image-comparison}
        #
        # You can handle settings for the comparision following below.
        # {https://github.com/appium/appium-base-driver/blob/master/lib/basedriver/device-settings.js#L6 device-settings}
        #
        # @param [String] img_path A path to a partial image you'd like to find
        #
        # @return [::Selenium::WebDriver::Element]
        #
        # @example
        #
        #     @@driver.update_settings({ fixImageFindScreenshotDims: false, fixImageTemplateSize: true,
        #                                autoUpdateImageElementPosition: true })
        #     e = @@driver.find_elements_by_image ['./test/functional/data/test_element_image.png']
        #     e == [] # if the 'e' is empty
        #
        def find_elements_by_image(img_path)
          template = Base64.strict_encode64 File.read img_path
          find_elements :image, template
        end

        # @since Appium 1.14.0
        #
        # Run a set of script against the current session, allowing execution of many commands in one Appium request.
        # Supports {https://webdriver.io/docs/api.html WebdriverIO} API so far.
        # Please read {http://appium.io/docs/en/commands/session/execute-driver command API} for more details
        # about acceptable scripts and the output.
        #
        # @param [String] script The string consisting of the script itself
        # @param [String] type The name of the script type.
        #                      Defaults to 'webdriverio'. Depends on server implementation which type is supported.
        # @param [Integer] timeout_ms The number of +ms+ Appium should wait for the script to finish
        #                          before killing it due to timeout.
        #
        # @return [Appium::Core::Base::Device::ExecuteDriver::Result] The script result parsed by
        #                          Appium::Core::Base::Device::ExecuteDriver::Result.
        #
        # @raise [::Selenium::WebDriver::Error::UnknownError] If something error happens in the script.
        #                                                     It has the original message.
        #
        # @example
        #      script = <<~SCRIPT
        #        const status = await driver.status();
        #        console.warn('warning message');
        #        return [status];
        #      SCRIPT
        #      r = @@driver.execute_driver(script: script, type: 'webdriverio', timeout: 10_000)
        #      r        #=> An instance of Appium::Core::Base::Device::ExecuteDriver::Result
        #      r.result #=> The 'result' key part as the result of the script
        #      r.logs   #=> The 'logs' key part as '{'log' => [], 'warn' => [], 'error' => []}'
        #
        def execute_driver(script: '', type: 'webdriverio', timeout_ms: nil)
          @bridge.execute_driver(script: script, type: type, timeout_ms: timeout_ms)
        end

        # Convert vanilla element response to ::Selenium::WebDriver::Element
        #
        # @param [Hash] id The id which can get as a response from server
        # @return [::Selenium::WebDriver::Element]
        #
        # @example
        #     response = {"element-6066-11e4-a52e-4f735466cecf"=>"xxxx", "ELEMENT"=>"xxxx"}
        #     ele = @driver.convert_to_element(response) #=> ::Selenium::WebDriver::Element
        #     ele.rect #=> Can get the rect of the element
        #
        def convert_to_element(id)
          @bridge.convert_to_element id
        end
      end # class Driver
    end # class Base
  end # module Core
end # module Appium
