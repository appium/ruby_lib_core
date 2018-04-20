require 'base64'

module Appium
  module Core
    module Device
      module ImageComparision
        extend Forwardable

        # matchTemplate:
        #     Performs images matching by template to find possible occurrence of the partial image
        #     in the full image with default options. Read https://docs.opencv.org/2.4/doc/tutorials/imgproc/histograms/template_matching/template_matching.html
        #     for more details on this topic.
        #

        MODE = [:matchFeatures, :getSimilarity, :matchTemplate].freeze

        # detectorName:
        #     Sets the detector name for features matching
        #     algorithm. Some of these detectors (FAST, AGAST, GFTT, FAST, SIFT and MSER) are not available
        #     in the default OpenCV installation and have to be enabled manually before
        #     library compilation. The default detector name is 'ORB'.
        # matchFunc:
        #     The name of the matching function. The default one is 'BruteForce'.
        # goodMatchesFactor:
        #     The maximum count of "good" matches (e. g. with minimal distances).
        MATCH_FEATURES = {
          detector_name: %w(AKAZE AGAST BRISK FAST GFTT KAZE MSER SIFT ORB),
          match_func: %w(FlannBased BruteForce BruteForceL1 BruteForceHamming BruteForceHammingLut BruteForceSL2),
          goodMatchesFactor: 100,
          visualize: [true, false]
        }.freeze

        MATCH_TEMPLATE = {
          visualize: [true, false]
        }.freeze

        GET_SIMILARITY = {
          visualize: [true, false]
        }.freeze

        def self.extended
          ::Appium::Core::Device.add_endpoint_method(:match_images_features) do
            def match_images_features(first_image:, # rubocop:disable Metrics/ParameterLists
                                      second_image:,
                                      detector_name: 'ORB',
                                      match_func: 'BruteForce',
                                      good_matches_factor: 100,
                                      visualize: false)
              unless MATCH_FEATURES[:detector_name].member?(detector_name)
                raise "detector_name should be #{MATCH_FEATURES[:detector_name]}"
              end
              unless MATCH_FEATURES[:match_func].member?(match_func)
                raise "match_func should be #{MATCH_FEATURES[:match_func]}"
              end
              unless MATCH_FEATURES[:visualize].member?(visualize)
                raise "visualize should be #{MATCH_FEATURES[:visualize]}"
              end

              options = {}
              options[:detectorName] = detector_name.upcase
              options[:matchFunc] = match_func
              options[:goodMatchesFactor] = good_matches_factor.to_i
              options[:visualize] = visualize

              compare_images(mode: :matchFeatures, first_image: first_image, second_image: second_image, options: options)
            end
          end

          ::Appium::Core::Device.add_endpoint_method(:find_image_occurrence) do
            def find_image_occurrence(first_image:, second_image:, visualize: false)
              unless MATCH_TEMPLATE[:visualize].member?(visualize)
                raise "visualize should be #{MATCH_TEMPLATE[:visualize]}"
              end

              options = {}
              options[:visualize] = visualize

              compare_images(mode: :matchTemplate, first_image: first_image, second_image: second_image, options: options)
            end
          end

          ::Appium::Core::Device.add_endpoint_method(:get_images_similarity) do
            def get_images_similarity(first_image:, second_image:, visualize: false)
              unless GET_SIMILARITY[:visualize].member?(visualize)
                raise "visualize should be #{GET_SIMILARITY[:visualize]}"
              end

              options = {}
              options[:visualize] = visualize

              compare_images(mode: :getSimilarity, first_image: first_image, second_image: second_image, options: options)
            end
          end

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
