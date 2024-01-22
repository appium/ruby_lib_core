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

require 'test_helper'
require 'base64'

# $ rake test:func:ios TEST=test/functional/ios/ios/image_comparison_test.rb
# rubocop:disable Style/ClassVars
class AppiumLibCoreTest
  module Ios
    # @since Appium 1.9.0
    class ImageComparisionTest < AppiumLibCoreTest::Function::TestCase
      def setup
        @@core = ::Appium::Core.for Caps.ios
        @@driver ||= @@core.start_driver

        @@driver.terminate_app Caps.bundle_id
        @@driver.activate_app Caps.bundle_id
      end

      def teardown
        save_reports(@@driver)
      end

      def test_image_comparison_match_result
        skip_as_appium_version '1.9.0'

        image1 = File.read './test/functional/data/test_normal.png'
        image2 = File.read './test/functional/data/test_has_blue.png'

        match_result = @@driver.match_images_features first_image: image1, second_image: image2
        assert_equal %w(points1 rect1 points2 rect2 totalCount count), match_result.keys

        match_result_visual = @@driver.match_images_features first_image: image1, second_image: image2, visualize: true
        assert_equal %w(points1 rect1 points2 rect2 totalCount count visualization), match_result_visual.keys
        File.open('match_result_visual.png', 'wb') { |f| f << Base64.decode64(match_result_visual['visualization']) }
        assert File.size? 'match_result_visual.png'

        File.delete 'match_result_visual.png'
      end

      def test_image_comparison_find_result
        skip_as_appium_version '1.9.0'

        image1 = File.read './test/functional/data/test_normal.png'
        image2 = File.read './test/functional/data/test_has_blue.png'

        find_result = @@driver.find_image_occurrence full_image: image1, partial_image: image2

        assert_equal({ 'x' => 0, 'y' => 0, 'width' => 750, 'height' => 1334 }, find_result['rect'])
        assert !find_result['score'].nil?

        assert_nil find_result['visualization']

        multiple = find_result['multiple']
        assert_equal(1, multiple.size)
        assert_equal({ 'x' => 0, 'y' => 0, 'width' => 750, 'height' => 1334 }, multiple.first['rect'])
        assert !multiple.first['score'].nil?

        find_result_visual = @@driver.find_image_occurrence full_image: image1, partial_image: image2, visualize: true
        assert_equal %w(rect score visualization multiple).to_set, find_result_visual.keys.to_set
        File.open('find_result_visual.png', 'wb') { |f| f << Base64.decode64(find_result_visual['visualization']) }
        assert File.size? 'find_result_visual.png'

        File.delete 'find_result_visual.png'
      end

      def test_image_comparison_get_images_result
        skip_as_appium_version '1.9.0'

        image1 = File.read './test/functional/data/test_normal.png'
        image2 = File.read './test/functional/data/test_has_blue.png'

        get_images_result = @@driver.get_images_similarity first_image: image1, second_image: image2

        assert_equal(get_images_result['score'] > 0.89, true)

        get_images_result_visual = @@driver.get_images_similarity first_image: image1, second_image: image2, visualize: true
        assert_equal %w(score visualization), get_images_result_visual.keys
        File.open('get_images_result_visual.png', 'wb') { |f| f << Base64.decode64(get_images_result_visual['visualization']) }
        assert File.size? 'get_images_result_visual.png'

        File.delete 'get_images_result_visual.png'
      end

      def test_image_element
        skip_as_appium_version '1.9.0'

        @@driver.update_settings(
          {
            fixImageTemplateScale: true,
            imageMatchThreshold: 0.9,
            getMatchedImageResult: true,
            checkForImageElementStaleness: false
          }
        )

        el = @@driver.find_element :accessibility_id, 'Buttons'
        @@driver.save_element_screenshot el, 'test/functional/data/test_ios_button.png'

        # sometimes animation affects here
        image_element =
          @@core.wait { @@driver.find_element_by_image AppiumLibCoreTest.path_of('test/functional/data/test_ios_button.png') }

        assert image_element.inspect
        assert image_element.hash
        assert image_element.id =~ /\Aappium-image-element-[a-z0-9\-]+/
        assert !image_element.visual.nil?

        el_location = el.location
        image_location = image_element.location
        assert_in_delta el_location.x, image_location.x, 2
        assert_in_delta el_location.y, image_location.y, 2

        el_size = el.size
        image_size = image_element.size
        assert_in_delta el_size.width, image_size.width, 2
        assert_in_delta el_size.height, image_size.height, 2

        el_rect = el.rect
        image_rect = image_element.rect
        assert_in_delta el_rect.x, image_rect.x, 2
        assert_in_delta el_rect.y, image_rect.y, 2
        assert_in_delta el_rect.width, image_rect.width, 2
        assert_in_delta el_rect.height, image_rect.height, 2

        assert_equal el.displayed?, image_element.displayed?
        image_element.click

        assert @@driver.find_element :accessibility_id, 'Person'
        @@driver.back

        @@driver.update_settings(
          {
            fixImageTemplateScale: true,
            imageMatchThreshold: 0.9,
            getMatchedImageResult: false
          }
        )
        image_element =
          @@core.wait { @@driver.find_element_by_image AppiumLibCoreTest.path_of('test/functional/data/test_ios_button.png') }
        assert_nil image_element.visual
      end

      def test_image_elements
        skip_as_appium_version '1.9.0'

        @@driver.update_settings(
          {
            fixImageTemplateScale: true,
            imageMatchThreshold: 0.9,
            checkForImageElementStaleness: false
          }
        )

        el = @@driver.find_element :accessibility_id, 'Buttons'
        el.save_screenshot 'test/functional/data/test_ios_button.png'

        image_elements = @@driver.find_elements_by_image AppiumLibCoreTest.path_of('test/functional/data/test_ios_button.png')
        # assert image_elements.size == 1, image_elements.size
        image_element = image_elements.last

        assert image_element.inspect
        assert image_element.hash
        assert image_element.id =~ /\Aappium-image-element-[a-z0-9\-]+/

        el_location = el.location
        image_location = image_element.location
        assert_in_delta el_location.x, image_location.x, 3
        assert_in_delta el_location.y, image_location.y, 3

        el_size = el.size
        image_size = image_element.size
        assert_in_delta el_size.width, image_size.width, 3
        assert_in_delta el_size.height, image_size.height, 3

        el_rect = el.rect
        image_rect = image_element.rect
        assert_in_delta el_rect.x, image_rect.x, 3
        assert_in_delta el_rect.y, image_rect.y, 3
        assert_in_delta el_rect.width, image_rect.width, 3
        assert_in_delta el_rect.height, image_rect.height, 3

        assert_equal el.displayed?, image_element.displayed?
        image_element.click

        assert @@driver.find_element :accessibility_id, 'Person'
        @@driver.back
      end
    end
  end
end
# rubocop:enable Style/ClassVars
