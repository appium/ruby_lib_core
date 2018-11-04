require 'test_helper'
require 'base64'

# $ rake test:func:ios TEST=test/functional/ios/ios/image_comparison_test.rb
# rubocop:disable Style/ClassVars
class AppiumLibCoreTest
  module Ios
    class ImageComparisionTest < AppiumLibCoreTest::Function::TestCase
      def setup
        @@core ||= ::Appium::Core.for(Caps.ios)
        @@driver ||= @@core.start_driver
      end

      def test_image_comparison_match_result
        image1 = File.read './test/functional/data/test_normal.png'
        image2 = File.read './test/functional/data/test_has_blue.png'

        match_result = @@driver.match_images_features first_image: image1, second_image: image2
        assert_equal %w(points1 rect1 points2 rect2 totalCount count), match_result.keys

        match_result_visual = @@driver.match_images_features first_image: image1, second_image: image2, visualize: true
        assert_equal %w(points1 rect1 points2 rect2 totalCount count visualization), match_result_visual.keys
        File.write 'match_result_visual.png', Base64.decode64(match_result_visual['visualization'])
        assert File.size? 'match_result_visual.png'

        File.delete 'match_result_visual.png'
      end

      def test_image_comparison_find_result
        image1 = File.read './test/functional/data/test_normal.png'
        image2 = File.read './test/functional/data/test_has_blue.png'

        find_result = @@driver.find_image_occurrence full_image: image1, partial_image: image2
        assert_equal({ 'rect' => { 'x' => 0, 'y' => 0, 'width' => 750, 'height' => 1334 } }, find_result)

        find_result_visual = @@driver.find_image_occurrence full_image: image1, partial_image: image2, visualize: true
        assert_equal %w(rect visualization), find_result_visual.keys
        File.write 'find_result_visual.png', Base64.decode64(find_result_visual['visualization'])
        assert File.size? 'find_result_visual.png'

        File.delete 'find_result_visual.png'
      end

      def test_image_comparison_get_images_result
        image1 = File.read './test/functional/data/test_normal.png'
        image2 = File.read './test/functional/data/test_has_blue.png'

        get_images_result = @@driver.get_images_similarity first_image: image1, second_image: image2
        assert_equal({ 'score' => 0.891606867313385 }, get_images_result)

        get_images_result_visual = @@driver.get_images_similarity first_image: image1, second_image: image2, visualize: true
        assert_equal %w(score visualization), get_images_result_visual.keys
        File.write 'get_images_result_visual.png', Base64.decode64(get_images_result_visual['visualization'])
        assert File.size? 'get_images_result_visual.png'

        File.delete 'get_images_result_visual.png'
      end
    end
  end
end
# rubocop:enable Style/ClassVars
