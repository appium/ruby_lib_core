require_relative 'search_context'

module Appium
  module Core
    class Base
      class Driver < ::Selenium::WebDriver::Driver
        include ::Selenium::WebDriver::DriverExtensions::UploadsFiles
        include ::Selenium::WebDriver::DriverExtensions::TakesScreenshot
        include ::Selenium::WebDriver::DriverExtensions::HasSessionId
        include ::Selenium::WebDriver::DriverExtensions::Rotatable
        include ::Selenium::WebDriver::DriverExtensions::HasRemoteStatus
        include ::Selenium::WebDriver::DriverExtensions::HasWebStorage

        include ::Appium::Core::Base::SearchContext

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
        def find_element_by_image(png_img_path, match_threshol = DEFAULT_MATCH_THRESHOLD)
          full_image = self.screenshot_as(:base64)

          options = {}
          options[:goodMatchesFactor] = (match_threshol * 100).to_i unless match_threshol.nil?

          params = {}
          params[:mode] = :matchTemplate
          params[:firstImage] = full_image
          params[:secondImage] = File.read(png_img_path)
          params[:options] = options if options

          result = begin
            self.execute(:compare_images, {}, params)
          rescue ::Selenium::WebDriver::Error::WebDriverError => e
            raise ::Appium::Core::Error::NoSuchElementError if e.message.include('Cannot find any occurrences')
            raise ::Appium::Core::Error::CoreError, e.message
          end

          if result['rect']
            ::Appium::Core::ImageElement.new(self, result['rect']['x'], result['rect']['y'], result['rect']['width'], result['rect']['height'])
          else
            raise ::Appium::Core::Error::NoSuchElementError
          end
        end

        def find_elements_by_image(png_img_paths, match_threshol = DEFAULT_MATCH_THRESHOLD)
          png_img_paths.reduce([]) do |acc, path|
            begin
              acc.push find_element_by_image(path, match_threshol)
            rescue ::Appium::Core::Error::NoSuchElementError => e
              ::Appium::Logger.info e
            end

            acc
          end
        end
      end # class Driver
    end # class Base
  end # module Core
end # module Appium
