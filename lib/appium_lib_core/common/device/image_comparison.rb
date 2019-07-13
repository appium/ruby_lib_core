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

require 'base64'

module Appium
  module Core
    class Base
      module Device
        module ImageComparison
          MODE = [:matchFeatures, :getSimilarity, :matchTemplate].freeze

          MATCH_FEATURES = {
            detector_name: %w(AKAZE AGAST BRISK FAST GFTT KAZE MSER SIFT ORB),
            match_func: %w(FlannBased BruteForce BruteForceL1 BruteForceHamming BruteForceHammingLut BruteForceSL2),
            goodMatchesFactor: nil, # Integer
            visualize: [true, false]
          }.freeze

          MATCH_TEMPLATE = {
            visualize: [true, false]
          }.freeze

          GET_SIMILARITY = {
            visualize: [true, false]
          }.freeze

          # Performs images matching by features with default options.
          # Read {https://docs.opencv.org/3.0-beta/doc/py_tutorials/py_feature2d/py_matcher/py_matcher.html py_matcher}
          # for more details on this topic.
          #
          # @param [String] first_image An image data. All image formats, that OpenCV library itself accepts, are supported.
          # @param [String] second_image An image data. All image formats, that OpenCV library itself accepts, are supported.
          # @param [String] detector_name Sets the detector name for features matching
          #                               algorithm. Some of these detectors (FAST, AGAST, GFTT, FAST, SIFT and MSER) are
          #                               not available in the default OpenCV installation and have to be enabled manually
          #                               before library compilation. The default detector name is 'ORB'.
          # @param [String] match_func The name of the matching function. The default one is 'BruteForce'.
          # @param [String] good_matches_factor The maximum count of "good" matches (e. g. with minimal distances).
          #                                     The default one is nil.
          # @param [Bool] visualize Makes the endpoint to return an image, which contains the visualized result of
          #                         the corresponding picture matching operation. This option is disabled by default.
          #
          # @example
          #     @driver.match_images_features first_image: "image data 1", second_image: "image data 2"
          #
          #     visual = @@driver.match_images_features first_image: image1, second_image: image2, visualize: true
          #     File.write 'match_images_visual.png', Base64.decode64(visual['visualization']) # if the image is PNG
          #
          def match_images_features(first_image:,
                                    second_image:,
                                    detector_name: 'ORB',
                                    match_func: 'BruteForce',
                                    good_matches_factor: nil,
                                    visualize: false)
            unless MATCH_FEATURES[:detector_name].member?(detector_name.to_s)
              raise "detector_name should be #{MATCH_FEATURES[:detector_name]}"
            end

            unless MATCH_FEATURES[:match_func].member?(match_func.to_s)
              raise "match_func should be #{MATCH_FEATURES[:match_func]}"
            end

            raise "visualize should be #{MATCH_FEATURES[:visualize]}" unless MATCH_FEATURES[:visualize].member?(visualize)

            options = {}
            options[:detectorName] = detector_name.to_s.upcase
            options[:matchFunc] = match_func.to_s
            options[:goodMatchesFactor] = good_matches_factor.to_i unless good_matches_factor.nil?
            options[:visualize] = visualize

            compare_images(mode: :matchFeatures, first_image: first_image, second_image: second_image, options: options)
          end

          # Performs images matching by template to find possible occurrence of the partial image
          # in the full image with default options. Read
          # {https://docs.opencv.org/2.4/doc/tutorials/imgproc/histograms/template_matching/template_matching.html
          # template_matching}
          # for more details on this topic.
          #
          # @param [String] full_image A full image data.
          # @param [String] partial_image A partial image data. All image formats, that OpenCV library itself accepts,
          #                                are supported.
          # @param [Bool] visualize Makes the endpoint to return an image, which contains the visualized result of
          #                         the corresponding picture matching operation. This option is disabled by default.
          # @param [Float] threshold [0.5] At what normalized threshold to reject
          #
          # @example
          #     @driver.find_image_occurrence full_image: "image data 1", partial_image: "image data 2"
          #
          #     visual = @@driver.find_image_occurrence full_image: image1, partial_image: image2, visualize: true
          #     File.write 'find_result_visual.png', Base64.decode64(visual['visualization']) # if the image is PNG
          #
          def find_image_occurrence(full_image:, partial_image:, visualize: false, threshold: nil)
            raise "visualize should be #{MATCH_TEMPLATE[:visualize]}" unless MATCH_TEMPLATE[:visualize].member?(visualize)

            options = {}
            options[:visualize] = visualize
            options[:threshold] = threshold unless threshold.nil?

            compare_images(mode: :matchTemplate, first_image: full_image, second_image: partial_image, options: options)
          end

          # Performs images matching to calculate the similarity score between them
          # with default options. The flow there is similar to the one used in +find_image_occurrence+
          # but it is mandatory that both images are of equal size.
          #
          # @param [String] first_image An image data. All image formats, that OpenCV library itself accepts, are supported.
          # @param [String] second_image An image data. All image formats, that OpenCV library itself accepts, are supported.
          # @param [Bool] visualize Makes the endpoint to return an image, which contains the visualized result of
          #                         the corresponding picture matching operation. This option is disabled by default.
          #
          # @example
          #     @driver.get_images_similarity first_image: "image data 1", second_image: "image data 2"
          #
          #     visual = @@driver.get_images_similarity first_image: image1, second_image: image2, visualize: true
          #     File.write 'images_similarity_visual.png', Base64.decode64(visual['visualization']) # if the image is PNG
          #
          def get_images_similarity(first_image:, second_image:, visualize: false)
            raise "visualize should be #{GET_SIMILARITY[:visualize]}" unless GET_SIMILARITY[:visualize].member?(visualize)

            options = {}
            options[:visualize] = visualize

            compare_images(mode: :getSimilarity, first_image: first_image, second_image: second_image, options: options)
          end

          # Performs images comparison using OpenCV framework features.
          # It is expected that both OpenCV framework and opencv4nodejs
          # module are installed on the machine where Appium server is running.
          #
          # @param [Symbol] mode One of possible comparison modes: +:matchFeatures+, +:getSimilarity+, +:matchTemplate+.
          #                      +:matchFeatures is by default.
          # @param [String] first_image An image data. All image formats, that OpenCV library itself accepts, are supported.
          # @param [String] second_image An image data. All image formats, that OpenCV library itself accepts, are supported.
          # @param [Hash] options The content of this dictionary depends on the actual +mode+ value.
          #                       See the documentation on +appium-support+ module for more details.
          # @return [Hash] The content of the resulting dictionary depends on the actual +mode+ and +options+ values.
          #                 See the documentation on +appium-support+ module for more details.
          #
          def compare_images(mode: :matchFeatures, first_image:, second_image:, options: nil)
            raise "content_type should be #{MODE}" unless MODE.member?(mode)

            params = {}
            params[:mode] = mode
            params[:firstImage] = Base64.strict_encode64 first_image
            params[:secondImage] = Base64.strict_encode64 second_image
            params[:options] = options if options

            execute(:compare_images, {}, params)
          end
        end # module ImageComparison
      end # module Device
    end # class Base
  end # module Core
end # module Appium
