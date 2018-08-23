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
            @core ||= ::Appium::Core.for(self, Caps.android)
            @driver ||= android_mock_create_session_w3c
          end

          def test_image_comparison
            stub_request(:post, "#{SESSION}/appium/compare_images")
              .with(body: { mode: :matchFeatures,
                            firstImage: Base64.encode64('image1'),
                            secondImage: Base64.encode64('image2') }.to_json)
              .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

            @driver.compare_images first_image: 'image1', second_image: 'image2'

            assert_requested(:post, "#{SESSION}/appium/compare_images", times: 1)
          end

          def test_image_comparison_match_images_features
            stub_request(:post, "#{SESSION}/appium/compare_images")
              .with(body: { mode: :matchFeatures,
                            firstImage: Base64.encode64('image1'),
                            secondImage: Base64.encode64('image2'),
                            options: { detectorName: 'ORB',
                                       matchFunc: 'BruteForce',
                                       goodMatchesFactor: 100,
                                       visualize: false } }.to_json)
              .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

            @driver.match_images_features first_image: 'image1', second_image: 'image2', good_matches_factor: 100

            assert_requested(:post, "#{SESSION}/appium/compare_images", times: 1)
          end

          def test_image_comparison_find_image_occurrence
            stub_request(:post, "#{SESSION}/appium/compare_images")
              .with(body: { mode: :matchTemplate,
                            firstImage: Base64.encode64('image1'),
                            secondImage: Base64.encode64('image2'),
                            options: { visualize: false } }.to_json)
              .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

            @driver.find_image_occurrence full_image: 'image1', partial_image: 'image2'

            assert_requested(:post, "#{SESSION}/appium/compare_images", times: 1)
          end

          def test_image_comparison_get_images_similarity
            stub_request(:post, "#{SESSION}/appium/compare_images")
              .with(body: { mode: :getSimilarity,
                            firstImage: Base64.encode64('image1'),
                            secondImage: Base64.encode64('image2'),
                            options: { visualize: false } }.to_json)
              .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

            @driver.get_images_similarity first_image: 'image1', second_image: 'image2'

            assert_requested(:post, "#{SESSION}/appium/compare_images", times: 1)
          end
        end # class ImageComparisonTest
      end # module W3C
    end # module Device
  end # module Android
end # class AppiumLibCoreTest
