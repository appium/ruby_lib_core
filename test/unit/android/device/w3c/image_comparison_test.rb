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
require 'webmock/minitest'

# $ rake test:unit TEST=test/unit/android/device/w3c/commands_test.rb
class AppiumLibCoreTest
  module Android
    module Device
      module W3C
        class ImageComparisonTest < Minitest::Test
          include AppiumLibCoreTest::Mock

          def setup
            @core ||= ::Appium::Core.for(Caps.android)
            @driver ||= android_mock_create_session_w3c
          end

          def test_image_comparison
            img1 = 'img1GgoAAAANSUhEUgAAAu4AAAU2CAIAAABFtaRRAAAAAXNSR0IArs4c6QAAABxpRE9UAAAAAgAAAAAAAA'
            img2 = 'img2GgoAAAANSUhEUgAAAu4AAAU2CAIAAABFtaRRAAAAAXNSR0IArs4c6QAAABxpRE9UAAAAAgAAAAAAAA'

            stub_request(:post, "#{SESSION}/appium/compare_images")
              .with(body: { mode: :matchFeatures,
                            firstImage: Base64.strict_encode64(img1),
                            secondImage: Base64.strict_encode64(img2) }.to_json)
              .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

            @driver.compare_images first_image: img1, second_image: img2

            assert_requested(:post, "#{SESSION}/appium/compare_images", times: 1)
          end

          def test_image_comparison_match_images_features
            img1 = 'img1GgoAAAANSUhEUgAAAu4AAAU2CAIAAABFtaRRAAAAAXNSR0IArs4c6QAAABxpRE9UAAAAAgAAAAAAAA'
            img2 = 'img2GgoAAAANSUhEUgAAAu4AAAU2CAIAAABFtaRRAAAAAXNSR0IArs4c6QAAABxpRE9UAAAAAgAAAAAAAA'

            stub_request(:post, "#{SESSION}/appium/compare_images")
              .with(body: { mode: :matchFeatures,
                            firstImage: Base64.strict_encode64(img1),
                            secondImage: Base64.strict_encode64(img2),
                            options: { detectorName: 'ORB',
                                       matchFunc: 'BruteForce',
                                       goodMatchesFactor: 100,
                                       visualize: false } }.to_json)
              .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

            @driver.match_images_features first_image: img1, second_image: img2, good_matches_factor: 100

            assert_requested(:post, "#{SESSION}/appium/compare_images", times: 1)
          end

          def test_image_comparison_find_image_occurrence
            img1 = 'img1GgoAAAANSUhEUgAAAu4AAAU2CAIAAABFtaRRAAAAAXNSR0IArs4c6QAAABxpRE9UAAAAAgAAAAAAAA'
            img2 = 'img2GgoAAAANSUhEUgAAAu4AAAU2CAIAAABFtaRRAAAAAXNSR0IArs4c6QAAABxpRE9UAAAAAgAAAAAAAA'

            stub_request(:post, "#{SESSION}/appium/compare_images")
              .with(body: { mode: :matchTemplate,
                            firstImage: Base64.strict_encode64(img1),
                            secondImage: Base64.strict_encode64(img2),
                            options: { visualize: false } }.to_json)
              .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

            @driver.find_image_occurrence full_image: img1, partial_image: img2

            assert_requested(:post, "#{SESSION}/appium/compare_images", times: 1)
          end

          def test_image_comparison_get_images_similarity
            img1 = 'img1GgoAAAANSUhEUgAAAu4AAAU2CAIAAABFtaRRAAAAAXNSR0IArs4c6QAAABxpRE9UAAAAAgAAAAAAAA'
            img2 = 'img2GgoAAAANSUhEUgAAAu4AAAU2CAIAAABFtaRRAAAAAXNSR0IArs4c6QAAABxpRE9UAAAAAgAAAAAAAA'

            stub_request(:post, "#{SESSION}/appium/compare_images")
              .with(body: { mode: :getSimilarity,
                            firstImage: Base64.strict_encode64(img1),
                            secondImage: Base64.strict_encode64(img2),
                            options: { visualize: false } }.to_json)
              .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

            @driver.get_images_similarity first_image: img1, second_image: img2

            assert_requested(:post, "#{SESSION}/appium/compare_images", times: 1)
          end
        end # class ImageComparisonTest
      end # module W3C
    end # module Device
  end # module Android
end # class AppiumLibCoreTest
