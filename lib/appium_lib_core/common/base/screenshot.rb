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
            ::Appium::Logger.warn 'name used for saved screenshot does not match file type. '\
                                  'It should end with .png extension'
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
        alias take_element_screenshot save_element_screenshot

        #
        # Return a PNG screenshot in the given format as a string
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

        # @since Appium 1.3.4
        # @!method save_viewport_screenshot
        # Save screenshot except for status bar while +@driver.save_screenshot+ save entire screen.
        #
        # @example
        #
        #   @driver.save_viewport_screenshot 'path/to/save.png' #=> Get the File instance of viewport_screenshot
        #
        def save_viewport_screenshot(png_path)
          extension = File.extname(png_path).downcase
          if extension != '.png'
            ::Appium::Logger.warn 'name used for saved screenshot does not match file type. '\
                                  'It should end with .png extension'
          end
          viewport_screenshot_encode64 = bridge.take_viewport_screenshot
          File.open(png_path, 'wb') { |f| f << viewport_screenshot_encode64.unpack('m')[0] }
        end
      end
    end
  end
end
