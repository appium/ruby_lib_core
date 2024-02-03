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
    # Implement useful features for element.
    # Patch for Selenium Webdriver.
    class Element < ::Selenium::WebDriver::Element
      ::Selenium::WebDriver::SearchContext.extra_finders = EXTRA_FINDERS

      include ::Appium::Core::Base::TakesScreenshot

      # Retuns the element id.
      #
      # @return [String]
      # @example
      #   e = @driver.find_element :accessibility_id, 'something'
      #   e.id
      #
      attr_reader :id

      # Returns the value of attributes like below. Read each platform to know more details.
      #
      # uiautomator2: https://github.com/appium/appium-uiautomator2-server/blob/203cc7e57ce477f3cff5d95b135d1b3450a6033a/app/src/main/java/io/appium/uiautomator2/utils/Attribute.java#L19
      #     checkable, checked, class, clickable, content-desc, enabled, focusable, focused
      #     long-clickable, package, password, resource-id, scrollable, selection-start, selection-end
      #     selected, text, bounds, index
      #
      # XCUITest automation name supports below attributes.
      #     UID, accessibilityContainer, accessible, enabled, frame,
      #     label, name, rect, type, value, visible, wdAccessibilityContainer,
      #     wdAccessible, wdEnabled, wdFrame, wdLabel, wdName, wdRect, wdType,
      #     wdUID, wdValue, wdVisible
      #
      # @return [String]
      #
      # @example
      #
      #   e = @driver.find_element :accessibility_id, 'something'
      #   e.value
      #   e.resource_id # call 'e.attribute "resource-id"'
      #
      def method_missing(method_name, *args, &block)
        ignore_list = [:to_hash]
        return if ignore_list.include? method_name

        respond_to?(method_name) ? attribute(method_name.to_s.tr('_', '-')) : super
      end

      def respond_to_missing?(*)
        true
      end

      # Alias for type
      alias type send_keys

      # @deprecated Use element send_keys instead.
      # Set the value to element directly
      #
      # @example
      #
      #   element.immediate_value 'hello'
      #
      def immediate_value(*value)
        ::Appium::Logger.warn(
          '[DEPRECATION] element.immediate_value is deprecated. Please use element.send_keys instead.'
        )
        @bridge.set_immediate_value @id, *value
      end

      # @deprecated Use element send_keys or 'mobile: replaceElementValue' for UIAutomator2 instead.
      # Replace the value to element directly
      #
      # @example
      #
      #   element.replace_value 'hello'
      #
      def replace_value(*value)
        ::Appium::Logger.warn(
          '[DEPRECATION] element.replace_value is deprecated. Please use element.send_keys instead, ' \
          'or "mobile: replaceElementValue" for UIAutomator2.'
        )
        @bridge.replace_value @id, *value
      end

      # For use with location_rel.
      #
      # @return [::Selenium::WebDriver::Point] the relative x, y in a struct. ex: { x: 0.50, y: 0.20 }
      #
      # @example
      #
      #   e = @driver.find_element :accessibility_id, 'something'
      #   e.location_rel @driver
      #
      def location_rel(driver)
        rect = self.rect
        location_x = rect.x.to_f
        location_y = rect.y.to_f

        size_width  = rect.width.to_f
        size_height = rect.height.to_f

        center_x = location_x + (size_width / 2.0)
        center_y = location_y + (size_height / 2.0)

        w = driver.window_size
        ::Selenium::WebDriver::Point.new "#{center_x} / #{w.width.to_f}", "#{center_y} / #{w.height.to_f}"
      end

      # Return an element screenshot as base64
      #
      # @return String Base 64 encoded string
      #
      # @example
      #
      #     element.screenshot #=> "iVBORw0KGgoAAAANSUhEUgAABDgAAAB+CAIAAABOPDa6AAAAAX"
      #
      def screenshot
        bridge.element_screenshot @id
      end

      # Return an element screenshot in the given format
      #
      # @param [:base64, :png] format
      # @return String screenshot
      #
      # @example
      #
      #     element.screenshot_as :base64 #=> "iVBORw0KGgoAAAANSUhEUgAABDgAAAB+CAIAAABOPDa6AAAAAX"
      #
      def screenshot_as(format)
        case format
        when :base64
          bridge.element_screenshot @id
        when :png
          bridge.element_screenshot(@id).unpack('m')[0]
        else
          raise Core::Error::UnsupportedOperationError, "unsupported format: #{format.inspect}"
        end
      end

      # Save an element screenshot to the given path
      #
      # @param [String] png_path A path to save the screenshot
      # @return [File] Path to the element screenshot.
      #
      # @example
      #
      #   element.save_screenshot("fine_name.png")
      #
      def save_screenshot(png_path)
        extension = File.extname(png_path).downcase
        if extension != '.png'
          ::Appium::Logger.warn 'name used for saved screenshot does not match file type. ' \
                                'It should end with .png extension'
        end
        File.open(png_path, 'wb') { |f| f << screenshot_as(:png) }
      end
    end # class Element
  end # module Core
end # module Appium
