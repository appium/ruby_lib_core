module Appium
  module Core
    #
    # ImageElement is an element for images by `find_element/s_by_image`
    # Experimental feature
    #
    class ImageElement
      include ::Appium::Core::Base::SearchContext

      def initialize(bridge, id)
        @bridge = bridge
        @id = id
      end

      def inspect
        format '#<%s:0x%x id=%s>', self.class, hash * 2, @id.inspect
      end

      def hash
        @id.hash ^ @bridge.hash
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
        @bridge.click_element @id
      end

      #
      # Submit this element
      #

      def submit
        @bridge.submit_element @id
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
        @bridge.element_location @id
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
        @bridge.element_size @id
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
        @bridge.element_rect @id
      end

      def displayed?
        @bridge.element_displayed? @id
      end

      def ref
        @id
      end

      #-------------------------------- sugar  --------------------------------

      #
      #   element.first(id: 'foo')
      #
      alias first find_element

      #
      #   element.all(class: 'bar')
      #
      alias all find_elements
    end
  end
end
