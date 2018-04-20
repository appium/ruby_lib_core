require 'base64'

module Appium
  module Core
    module Device
      module ImageComparision
        extend Forwardable

        MODE = [:matchFeatures, :getSimilarity, :matchTemplate].freeze

        def self.extended
          ::Appium::Core::Device.add_endpoint_method(:compare_images) do
            # @!method compare_images(mode: :matchFeatures, first_image:, second_image:, options: nil)
            #
            # Performs images comparison using OpenCV framework features.
            # It is expected that both OpenCV framework and opencv4nodejs
            # module are installed on the machine where Appium server is running.
            #
            # @param [Symbol] mode: One of possible comparison modes: `:matchFeatures`, `:getSimilarity`, `:matchTemplate`.
            #                       `:matchFeatures is by default.
            # @param [String] first_image An image file. All image formats, that OpenCV library itself accepts, are supported.
            # @param [String] second_image An image file. All image formats, that OpenCV library itself accepts, are supported.
            # @param [Hash] options The content of this dictionary depends on the actual `mode` value.
            #               See the documentation on `appium-support` module for more details.
            # @returns [Hash] The content of the resulting dictionary depends on the actual `mode` and `options` values.
            #                 See the documentation on `appium-support` module for more details.
            #
            def compare_images(mode: :matchFeatures, first_image:, second_image:, options: nil)
              unless ::Appium::Core::Device::ImageComparision::MODE.member?(mode)
                raise "content_type should be #{::Appium::Core::Device::ImageComparision::MODE}"
              end

              params = {}
              params[:mode] = mode
              params[:firstImage] = Base64.encode64 first_image
              params[:secondImage] = Base64.encode64 second_image
              params[:options] = options if options

              execute(:compare_images, {}, params)
            end
          end
        end # self
      end # module ImageComparision
    end # module Device
  end # module Core
end # module Appium
