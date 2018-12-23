require 'test_helper'
require 'webmock/minitest'
require 'base64'

# $ rake test:unit TEST=test/unit/android/device/mjsonwp/image_comparison_test.rb
class AppiumLibCoreTest
  module Android
    module Device
      module MJSONWP
        class ImageComparisonTest < Minitest::Test
          include AppiumLibCoreTest::Mock

          def setup
            @core ||= ::Appium::Core.for(Caps.android)
            @driver ||= android_mock_create_session
          end

          def test_image_comparison
            stub_request(:post, "#{SESSION}/appium/compare_images")
              .with(body: { mode: :matchFeatures,
                            firstImage: Base64.strict_encode64('image1'),
                            secondImage: Base64.strict_encode64('image2') }.to_json)
              .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

            @driver.compare_images first_image: 'image1', second_image: 'image2'

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
        end # class Commands
      end # module MJSONWP
    end # module Device
  end # module Android
end # class AppiumLibCoreTest
