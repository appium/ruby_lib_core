require 'base64'

module Appium
  module Core
    module Device
      extend Forwardable

      ####
      ## No argument
      ####

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

      # @!method is_keyboard_shown
      # Get whether keyboard is displayed or not.
      # @return [Bool] Return true if keyboard is shown. Return false if keyboard is hidden.
      #
      # @example
      #   @driver.is_keyboard_shown # false
      #

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

      # @!method toggle_flight_mode
      # Toggle flight mode on or off
      #
      # @example
      #
      #   @driver.toggle_flight_mode
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

      # @!method get_network_connection
      #   Get the device network connection current status
      #   See set_network_connection method for return value
      #
      # @example
      #
      #   @driver.network_connection_type #=> 6
      #   @driver.get_network_connection  #=> 6
      #

      # @!method open_notifications
      #   Open Android notifications
      #
      # @example
      #
      #   @driver.open_notifications
      #

      # @!method device_time
      #   Get the time on the device
      # @return [String]
      #
      # @example
      #
      #   @driver.device_time
      #

      ####
      ## With arguments
      ####

      # @!method install_app(path)
      # Install the given app onto the device
      #
      # @example
      #
      #   @driver.install_app("/path/to/test.apk")
      #

      # @!method remove_app(app_id)
      # Install the given app onto the device
      #
      # @example
      #
      #   @driver.remove_app("io.appium.bundle")
      #

      # @!method app_installed?(app_id)
      # Check whether the specified app is installed on the device
      # @return [bool]
      #
      # @example
      #
      #   @driver.app_installed?("io.appium.bundle")
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
      #   @driver.lock(5) #=> Lock the device in 5 sec and unlock the device after 5 sec
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

      # @!method press_keycode(key, metastate = nil)
      # Press keycode on the device.
      # http://developer.android.com/reference/android/view/KeyEvent.html
      # @param [integer] key The key to press.
      # @param [String] metastate The state the metakeys should be in when pressing the key.
      #
      # @example
      #
      #   @driver.press_keycode 82
      #

      # @!method long_press_keycode(key, metastate = nil)
      # Long press keycode on the device.
      # http://developer.android.com/reference/android/view/KeyEvent.html
      # @param [integer] key The key to long press.
      # @param [String] metastate The state the metakeys should be in when long pressing the key.
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

      ####
      ## class << self
      ####

      class << self
        def extended(_mod)
          extend_webdriver_with_forwardable

          ::Appium::Core::Commands::COMMAND_NO_ARG.each_key do |method|
            add_endpoint_method method
          end

          add_endpoint_method(:available_contexts) do
            def available_contexts
              # return empty array instead of nil on failure
              execute(:available_contexts, {}) || []
            end
          end

          add_endpoint_method(:app_strings) do
            def app_strings(language = nil)
              opts = language ? { language: language } : {}
              execute :app_strings, {}, opts
            end
          end

          add_endpoint_method(:lock) do
            def lock(duration = nil)
              opts = duration ? { seconds: duration } : {}
              execute :lock, {}, opts
            end
          end

          add_endpoint_method(:install_app) do
            def install_app(path)
              execute :install_app, {}, appPath: path
            end
          end

          add_endpoint_method(:remove_app) do
            def remove_app(id)
              execute :remove_app, {}, appId: id
            end
          end

          add_endpoint_method(:app_installed?) do
            def app_installed?(app_id)
              execute :app_installed?, {}, bundleId: app_id
            end
          end

          add_endpoint_method(:background_app) do
            def background_app(duration = 0)
              execute :background_app, {}, seconds: duration
            end
          end

          add_endpoint_method(:set_context) do
            def set_context(context = null)
              execute :set_context, {}, name: context
            end
          end

          add_endpoint_method(:hide_keyboard) do
            def hide_keyboard(close_key = nil, strategy = nil)
              option = {}

              option[:key] = close_key || 'Done'        # default to Done key.
              option[:strategy] = strategy || :pressKey # default to pressKey

              execute :hide_keyboard, {}, option
            end
          end

          add_endpoint_method(:take_element_screenshot) do
            def take_element_screenshot(element, png_path)
              result = execute :take_element_screenshot, id: element.ref

              extension = File.extname(png_path).downcase
              if extension != '.png'
                WebDriver.logger.warn 'name used for saved screenshot does not match file type. '\
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

          add_keyevent
          add_touch_actions
          add_ime_actions
          add_handling_context
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

        # @private
        def delegate_driver_method(method)
          return if ::Appium::Core::Base::Driver.method_defined? method
          ::Appium::Core::Base::Driver.class_eval { def_delegator :@bridge, method }
        end

        # @private
        def delegate_from_appium_driver(method, delegation_target = :driver)
          def_delegator delegation_target, method
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
            def press_keycode(key, metastate = nil)
              args             = { keycode: key }
              args[:metastate] = metastate if metastate
              execute :press_keycode, {}, args
            end
          end

          add_endpoint_method(:long_press_keycode) do
            def long_press_keycode(key, metastate = nil)
              args             = { keycode: key }
              args[:metastate] = metastate if metastate
              execute :long_press_keycode, {}, args
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
        end
      end # class << self
    end # module Device
  end # module Core
end # module Appium
