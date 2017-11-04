module Appium
  module Core
    # Implement useful features for element.
    class Selenium::WebDriver::Element
      # Note: For testing .text should be used over value, and name.

      # Returns the value attribute
      #
      # Fixes NoMethodError: undefined method `value' for Selenium::WebDriver::Element
      def value
        attribute :value
      end

      # Returns the name attribute
      #
      # Fixes NoMethodError: undefined method `name' for Selenium::WebDriver::Element
      def name
        attribute :name
      end

      # Enable access to iOS accessibility label
      # accessibility identifier is supported as 'name'
      def label
        attribute :label
      end

      # Alias for type
      alias type send_keys

      # For use with location_rel.
      #
      # @return [::Selenium::WebDriver::Point] the relative x, y in a struct. ex: { x: 0.50, y: 0.20 }
      #
      # @example
      #
      #   location_rel @driver
      #
      def location_rel(driver)
        rect   = self.rect
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
