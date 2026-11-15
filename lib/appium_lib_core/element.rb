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
      # Attributes returned with an element response. This object has no bridge:
      # reading it never sends a command or refreshes the returned values.
      class Cache
        attr_reader :attributes

        def initialize(attributes = {})
          @attributes = attributes.dup.freeze
        end

        # Normalize standard response fields; arbitrary attribute/... values stay raw.
        # Missing attributes return nil. The original values remain in attributes.
        def attribute(name)
          key = attribute_key(name)
          value = @attributes[key]
          case name.to_s
          when 'enabled', 'displayed', 'selected'
            return true if value == 'true'
            return false if value == 'false'
          when 'rect'
            return ::Selenium::WebDriver::Rectangle.new(value['x'], value['y'], value['width'], value['height']) if value.is_a?(Hash)
          end
          value
        end

        alias [] attribute

        def enabled?
          attribute('enabled')
        end

        alias enabled enabled?

        def displayed?
          attribute('displayed')
        end

        alias displayed displayed?

        def selected?
          attribute('selected')
        end

        alias selected selected?

        def rect
          attribute('rect')
        end

        def location
          rectangle = rect
          ::Selenium::WebDriver::Point.new(rectangle.x, rectangle.y) if rectangle
        end

        def size
          rectangle = rect
          ::Selenium::WebDriver::Dimension.new(rectangle.width, rectangle.height) if rectangle
        end

        def tag_name
          attribute('name')
        end

        def method_missing(name, *args, &block)
          return super unless args.empty? && block.nil? && respond_to_missing?(name)

          attribute(name.to_s.delete_suffix('?').tr('_', '-'))
        end

        def respond_to_missing?(name, include_private = false)
          @attributes.key?(attribute_key(name.to_s.delete_suffix('?').tr('_', '-'))) || super
        end

        private

        def attribute_key(name)
          key = name.to_s
          @attributes.key?("attribute/#{key}") ? "attribute/#{key}" : key
        end
      end

      include ::Appium::Core::Base::TakesScreenshot

      # steep:ignore:start
      ::Selenium::WebDriver::SearchContext.extra_finders = ::Appium::Core::Base::SearchContext::APPIUM_EXTRA_FINDERS
      # steep:ignore:end

      # Retuns the element id.
      #
      # @return [String]
      # @example
      #   e = @driver.find_element :accessibility_id, 'something'
      #   e.id
      #
      attr_reader :id

      def initialize(bridge, id, cached = nil)
        if id.is_a?(Hash)
          # Preserve any extra attributes included in the element response.
          cached = Cache.new(id.except(ELEMENT_KEY))
          id = id[ELEMENT_KEY]
        end
        raise ::Selenium::WebDriver::Error::WebDriverError, 'Missing W3C element ID in response' if id.nil?

        super(bridge, id)
        @cached = cached
      end

      # Snapshot from elementResponseAttributes with shouldUseCompactResponses=false.
      # Normal element calls still query the server and do not update this snapshot.
      # Standard fields use Element API types; cached.attributes holds server values.
      # @return [Appium::Core::Element::Cache]
      def cached
        @cached ||= Cache.new
      end

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

      def respond_to_missing?(_method_name, _include_private = false)
        true
      end

      # Alias for type
      alias type send_keys

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
          raise ::Appium::Core::Error::UnsupportedOperationError, "unsupported format: #{format.inspect}"
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
