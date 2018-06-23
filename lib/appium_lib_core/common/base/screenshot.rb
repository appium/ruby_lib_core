module Appium
  module Core
    class Base
      module TakeScreenshot
        #
        # Save a PNG screenshot to the given path
        #
        # @api public
        #
        def save_screenshot(png_path)
          extension = File.extname(png_path).downcase
          if extension != '.png'
            ::Appium::Logger.warn "name used for saved screenshot does not match file type. "\
                                  "It should end with .png extension"
          end
          File.open(png_path, 'wb') { |f| f << screenshot_as(:png) }
        end

        #
        # Return a PNG screenshot in the given format as a string
        #
        # @param [:base64, :png] format
        # @return String screenshot
        #
        # @example
        #
        #     @@driver.screenshot_as :base64 #=> "iVBORw0KGgoAAAANSUhEUgAABDgAAAB+CAIAAABOPDa6AAAAAX"
        #
        # @api public
        def screenshot_as(format)
          case format
          when :base64
            bridge.screenshot
          when :png
            bridge.screenshot.unpack('m')[0]
          else
            raise Core::Error::UnsupportedOperationError, "unsupported format: #{format.inspect}"
          end
        end

        # @param [Selenium::WebDriver::Element] element A element you'd like to take screenshot.
        # @param [String] png_path A path to save the screenshot
        # @return [File] Path to the screenshot.
        #
        # @example
        #
        #   @driver.save_element_screenshot(element, "fine_name.png")
        #
        def save_element_screenshot(element, png_path)
          extension = File.extname(png_path).downcase
          if extension != '.png'
            ::Appium::Logger.warn 'name used for saved screenshot does not match file type. '\
                                'It should end with .png extension'
          end
          File.open(png_path, 'wb') { |f| f << element_screenshot_as(element, :png) }
        end
        # backward compatibility
        alias_method :take_element_screenshot, :save_element_screenshot

        #
        # Return a png or base64 formatted screenshot
        #
        # @param [:base64, :png] format
        # @return String screenshot
        #
        # @example
        #
        #     @@driver.element_screenshot_as element, :base64 #=> "iVBORw0KGgoAAAANSUhEUgAABDgAAAB+CAIAAABOPDa6AAAAAX"
        #
        def element_screenshot_as(element, format)
          case format
          when :base64
            bridge.take_element_screenshot(element)
          when :png
            bridge.take_element_screenshot(element).unpack('m')[0]
          else
            raise Core::Error::UnsupportedOperationError, "unsupported format: #{format.inspect}"
          end
        end
      end
    end
  end
end
