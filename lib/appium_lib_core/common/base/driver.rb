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

        # Lock
        def lock(duration = nil)
          @bridge.lock(duration)
        end

        def device_locked?
          @bridge.device_locked?
        end

        def unlock
          @bridge.unlock
        end

        # Keyboard
        def hide_keyboard(close_key = nil, strategy = nil)
          @bridge.hide_keyboard close_key, strategy
        end

        def is_keyboard_shown # rubocop:disable Naming/PredicateName
          @bridge.is_keyboard_shown
        end

        # Setting
        def get_settings
          @bridge.get_settings
        end

        def update_settings(settings)
          @bridge.update_settings(settings)
        end

        # IME
        def ime_activate(ime_name)
          @bridge.ime_activate(ime_name)
        end

        def ime_available_engines
          @bridge.ime_available_engines
        end

        def ime_active_engine
          @bridge.ime_active_engine
        end

        def ime_activated
          @bridge.ime_activated
        end

        def ime_deactivate
          @bridge.ime_deactivate
        end

        # Context
        def within_context(context)
          @bridge.within_context(context)
        end

        def switch_to_default_context
          @bridge.switch_to_default_context
        end

        def current_context
          @bridge.current_context
        end

        def available_contexts
          @bridge.available_contexts
        end

        def set_context(context = null)
          @bridge.set_context(context)
        end

        # Value
        def set_immediate_value(element, *value)
          @bridge.set_immediate_value(element, *value)
        end

        def replace_value(element, *value)
          @bridge.replace_value(element, *value)
        end

        # File Management
        def push_file(path, filedata)
          @bridge.push_file(path, filedata)
        end

        def pull_file(path)
          @bridge.pull_file(path)
        end

        def pull_folder(path)
          @bridge.pull_folder(path)
        end

        # Keyevent
        def keyevent(key, metastate = nil)
          @bridge.keyevent(key, metastate)
        end

        def press_keycode(key, metastate: [], flags: [])
          @bridge.press_keycode(key, metastate: metastate, flags: flags)
        end

        def long_press_keycode(key, metastate: [], flags: [])
          @bridge.long_press_keycode(key, metastate: metastate, flags: flags)
        end

        # App Management
        def launch_app
          @bridge.launch_app
        end

        def close_app
          @bridge.close_app
        end

        def reset
          @bridge.reset
        end

        def app_strings(language = nil)
          @bridge.app_strings(language)
        end

        def background_app(duration = 0)
          @bridge.background_app(duration)
        end

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

        def remove_app(id, keep_data: nil, timeout: nil)
          @bridge.remove_app(id, keep_data: keep_data, timeout: timeout)
        end

        def app_installed?(app_id)
          @bridge.app_installed?(app_id)
        end

        def activate_app(app_id)
          @bridge.activate_app(app_id)
        end

        def terminate_app(app_id, timeout: nil)
          @bridge.terminate_app(app_id, timeout: timeout)
        end

        # AppState
        def app_state(app_id)
          @bridge.app_state(app_id)
        end

        # Screen Record
        def stop_recording_screen(remote_path: nil, user: nil, pass: nil, method: 'PUT')
          @bridge.stop_recording_screen(remote_path: remote_path, user: user, pass: pass, method: method)
        end

        def stop_and_save_recording_screen(file_path)
          @bridge.stop_and_save_recording_screen(file_path)
        end

        # Device Handling
        def shake
          @bridge.shake
        end

        def device_time(format = nil)
          @bridge.device_time(format)
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
        # It's almost same as `@driver.capabilities` but you can get more details.
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
        #   #           "app"=>"/path/to/app/api.apk",
        #   #           "platformVersion"=>"8.1.0",
        #   #           "deviceName"=>"Android Emulator",
        #   #           "appPackage"=>"io.appium.android.apis",
        #   #           "appActivity"=>"io.appium.android.apis.ApiDemos",
        #   #           "someCapability"=>"some_capability",
        #   #           "unicodeKeyboard"=>true,
        #   #           "resetKeyboard"=>true},
        #   #      "automationName"=>"uiautomator2",
        #   #      "app"=>"/path/to/app/api.apk",
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
        #   #      "platformVersion"=>"10.3",
        #   #      "deviceName"=>"iPhone Simulator",
        #   #      "useNewWDA"=>true,
        #   #      "useJSONSource"=>true,
        #   #      "someCapability"=>"some_capability",
        #   #      "sdkVersion"=>"10.3.1",
        #   #      "CFBundleIdentifier"=>"com.example.apple-samplecode.UICatalog",
        #   #      "pixelRatio"=>2,
        #   #      "statBarHeight"=>23.4375,
        #   #      "viewportRect"=>{"left"=>0, "top"=>47, "width"=>750, "height"=>1287}}>
        #
        def session_capabilities
          @bridge.session_capabilities
        end

        DEFAULT_MATCH_THRESHOLD = 0.5

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

        # Return ImageElement if current view has a partial image
        #
        # @param [String] png_img_path A path to a partial image you'd like to find
        # @param [Flood] match_threshold At what normalized threshold to reject
        # @param [Bool] visualize Makes the endpoint to return an image, which contains the visualized result of
        #                         the corresponding picture matching operation. This option is disabled by default.
        #
        # @return [::Appium::Core::ImageElement]
        # @raise [::Appium::Core::Error::NoSuchElementError|::Appium::Core::Error::CoreError] No such element
        #
        # @example
        #
        #     e = @@driver.find_element_by_image './test/functional/data/test_element_image.png'
        #
        def find_element_by_image(png_img_path, match_threshold: DEFAULT_MATCH_THRESHOLD, visualize: false)
          full_image = @bridge.screenshot
          partial_image = Base64.encode64 File.read(png_img_path)

          element = begin
            @bridge.find_element_by_image(full_image: full_image,
                                          partial_image: partial_image,
                                          match_threshold: match_threshold,
                                          visualize: visualize)
          rescue Selenium::WebDriver::Error::TimeOutError
            raise ::Appium::Core::Error::NoSuchElementError
          rescue ::Selenium::WebDriver::Error::WebDriverError => e
            raise ::Appium::Core::Error::NoSuchElementError if e.message.include?('Cannot find any occurrences')
            raise ::Appium::Core::Error::CoreError, e.message
          end
          raise ::Appium::Core::Error::NoSuchElementError if element.nil?

          element
        end

        # Return ImageElement if current view has partial images
        #
        # @param [[String]] png_img_paths Paths to a partial image you'd like to find
        # @param [Flood] match_threshold At what normalized threshold to reject
        # @param [Bool] visualize Makes the endpoint to return an image, which contains the visualized result of
        #                         the corresponding picture matching operation. This option is disabled by default.
        #
        # @return [[::Appium::Core::ImageElement]]
        # @return [::Appium::Core::Error::CoreError]
        #
        # @example
        #
        #     e = @@driver.find_elements_by_image ['./test/functional/data/test_element_image.png']
        #     e == [] # if the `e` is empty
        #
        def find_elements_by_image(png_img_paths, match_threshold: DEFAULT_MATCH_THRESHOLD, visualize: false)
          full_image = @bridge.screenshot

          partial_images = png_img_paths.map do |png_img_path|
            Base64.encode64 File.read(png_img_path)
          end

          begin
            @bridge.find_elements_by_image(full_image: full_image,
                                           partial_images: partial_images,
                                           match_threshold: match_threshold,
                                           visualize: visualize)
          rescue Selenium::WebDriver::Error::TimeOutError
            []
          rescue ::Selenium::WebDriver::Error::WebDriverError => e
            return [] if e.message.include?('Cannot find any occurrences')
            raise ::Appium::Core::Error::CoreError, e.message
          end
        end
      end # class Driver
    end # class Base
  end # module Core
end # module Appium
