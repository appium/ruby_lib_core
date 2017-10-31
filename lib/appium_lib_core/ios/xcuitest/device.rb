module Appium
  module Ios
    module Xcuitest
      module Device
        extend Forwardable

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

        ####
        ## class << self
        ####

        class << self
          def extended(_mod)
            ::Appium::Core::Device.extend_webdriver_with_forwardable

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
          end
        end # class << self
      end # module Device
    end # module Xcuitest
  end # module Ios
end # module Appium
