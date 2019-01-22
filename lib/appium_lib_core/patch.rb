# rubocop:disable Style/ClassAndModuleChildren
module Appium
  module Core
    # Implement useful features for element.
    # Patch for Selenium Webdriver.
    class Selenium::WebDriver::Element
      # To extend Appium related SearchContext into ::Selenium::WebDriver::Element
      include ::Appium::Core::Base::SearchContext

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
      #   e.resource_id # call `e.attribute "resource-id"`
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
    end
  end # module Core
end # module Appium
# rubocop:enable Style/ClassAndModuleChildren
