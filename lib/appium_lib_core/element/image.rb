module Appium
  module Core
    class ImageElement
      Point     = Struct.new(:x, :y)
      Dimension = Struct.new(:width, :height)
      Rectangle = Struct.new(:x, :y, :width, :height)
      Location  = Struct.new(:latitude, :longitude, :altitude)

      def initialize(driver, x, y, width, height)
        @driver = driver

        @data = {}
        @data[:center_x] = x + width / 2
        @data[:center_y] = y + height / 2
        @data[:x] = x
        @data[:y] = y
        @data[:width] = width
        @data[:height] = height
      end

      def click
        TouchAction.new(@driver).tap(x: @data[:center_x], y: @data[:center_y]).perform
      end

      def location
        Point.new @data[:x], @data[:y]
      end

      def size
        Dimension.new @data[:width], @data[:height]
      end

      def rect
        Rectangle.new @data[:x], @data[:y], @data[:width], @data[:height]
      end

      def displayed?
        true
      end
    end
  end
end
