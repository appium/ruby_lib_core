module Appium
  module Core
    #
    # ImageElement is an element for images by `find_element/s_by_image`
    #
    class ImageElement
      Point     = Struct.new(:x, :y)
      Dimension = Struct.new(:width, :height)
      Rectangle = Struct.new(:x, :y, :width, :height)

      # Base64ed format
      # @example
      #
      #     File.write 'result.png', Base64.decode64(e.visual)
      #
      attr_reader :visual

      def initialize(bridge, x, y, width, height, visual = nil) # rubocop:disable Metrics/ParameterLists
        @bridge = bridge
        @visual = visual

        @center_x = x + width / 2
        @center_y = y + height / 2
        @x = x
        @y = y
        @width = width
        @height = height
      end

      #
      # Click this element.
      #
      # @example
      #
      #     e = @@driver.find_element_by_image './test/functional/data/test_element_image.png'
      #     e.click
      #
      def click
        @bridge.action.move_to_location(@center_x, @center_y).click.perform
      end

      #
      # Get the location of this element.
      #
      # @return [Point]
      #
      # @example
      #
      #     e = @@driver.find_element_by_image './test/functional/data/test_element_image.png'
      #     assert_equal [39, 1014], [e.location.x, e.location.y]
      #
      def location
        Point.new @x, @y
      end

      #
      # Get the size of this element
      #
      # @return [Dimension]
      #
      # @example
      #
      #     e = @@driver.find_element_by_image './test/functional/data/test_element_image.png'
      #         assert_equal [326, 62], [e.size.width, e.size.height]
      #
      def size
        Dimension.new @width, @height
      end

      #
      # Get the dimensions and coordinates of this element.
      #
      # @return [Rectangle]
      #
      # @example
      #
      #     e = @@driver.find_element_by_image './test/functional/data/test_element_image.png'
      #         assert_equal([39, 1014, 326, 62], [e.rect.x, e.rect.y, e.rect.width, e.rect.height])
      #
      def rect
        Rectangle.new @x, @y, @width, @height
      end

      def displayed?
        true
      end

      #-------------------------------- sugar  --------------------------------

      def first(full_image:, partial_image:, match_threshold: nil, visualize: false)
        @bridge.find_element_by_image(full_image: full_image,
                                      partial_image: partial_image,
                                      match_threshold: match_threshold,
                                      visualize: visualize)
      end

      def all(full_image:, partial_image:, match_threshold: nil, visualize: false)
        @bridge.find_elements_by_image(full_image: full_image,
                                       partial_image: partial_image,
                                       match_threshold: match_threshold,
                                       visualize: visualize)
      end
    end
  end
end
