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
require 'functional/common_w3c_actions'

# $ rake test:func:ios TEST=test/functional/ios/webdriver/device_test.rb
# rubocop:disable Style/ClassVars
class AppiumLibCoreTest
  module WebDriver
    class DeviceTest < AppiumLibCoreTest::Function::TestCase
      private

      def alert_view_cell
        if over_ios17? @@driver
          'Alert Views'
        elsif over_ios13? @@driver
          'Alert Controller'
        else
          'Alert Views'
        end
      end

      def okay_cancel_cell
        if over_ios17? @@driver
          'Okay / Cancel'
        elsif over_ios13? @@driver
          'OK / Cancel'
        else
          'Okay / Cancel'
        end
      end

      public

      def setup
        @@core = ::Appium::Core.for(Caps.ios)
        @@driver = @@core.start_driver
      end

      def teardown
        save_reports(@@driver)
      end

      def test_capabilities
        assert @@driver.capabilities
      end

      def test_remote_status
        status = @@driver.remote_status

        assert !status['build']['version'].nil?
      end

      def by_predicate(value)
        %(name ==[c] "#{value}" || label ==[c] "#{value}" || value ==[c] "#{value}")
      end

      def test_page_source
        require 'json'
        require 'rexml/document'

        # On the session
        s_source = @@driver.page_source
        s_xml = REXML::Document.new s_source

        assert s_source.include?('AppiumAUT')
        assert s_source.include?('XCUIElementTypeApplication type')

        # non session
        skip_as_appium_version '1.8.0' # No session source had an issue in 1.7.1

        response = Net::HTTP.get(URI("http://localhost:#{@@driver.capabilities['wdaLocalPort']}/source"))
        source = JSON.parse(response)['value']
        xml = REXML::Document.new source

        assert !source.include?('AppiumAUT')
        assert source.include?('XCUIElementTypeApplication type')
        assert xml[2].elements.each('//*') { |v| v }.map(&:name).size > 70 # rubocop:disable Lint/Void

        # Roughly matching...
        assert s_xml[2].elements.each('//*') { |v| v }.map(&:name).size > 70 # rubocop:disable Lint/Void
      end

      def test_location
        skip 'skip because set_location is unstable on CI' if ci?

        latitude = 10
        longitude = 10
        altitude = 75
        @@driver.set_location(latitude, longitude, altitude)

        if newer_appium_than_or_beta? '1.20.0'
          error = assert_raises ::Selenium::WebDriver::Error::UnknownError do
            @@driver.location
          end
          assert error.message.include? 'Location service must be'
        else
          error = assert_raises ::Selenium::WebDriver::Error::UnknownMethodError do
            @@driver.location
          end
          assert error.message.include? 'Method has not yet been implemented'
        end
      end

      def test_accept_alert
        @@core.wait { @@driver.find_element :accessibility_id, alert_view_cell }.click
        @@core.wait { @@driver.find_element :accessibility_id, okay_cancel_cell }.click

        @@core.wait { assert @@driver.switch_to.alert.text.downcase.start_with?('A Short Title Is Best'.downcase) }
        @@driver.switch_to.alert.accept

        @@core.wait { assert_raises(Selenium::WebDriver::Error::NoSuchAlertError) { @@driver.switch_to.alert } }
        @@driver.back
      end

      # NOTE: Sometimes this test fails because of getting nil in @@driver.switch_to.alert.text
      def test_dismiss_alert
        @@core.wait { @@driver.find_element :accessibility_id, alert_view_cell }.click
        @@core.wait { @@driver.find_element :accessibility_id, okay_cancel_cell }.click

        @@core.wait { assert @@driver.switch_to.alert.text.downcase.start_with?('A Short Title Is Best'.downcase) }
        @@driver.switch_to.alert.dismiss

        @@core.wait { assert_raises(Selenium::WebDriver::Error::NoSuchAlertError) { @@driver.switch_to.alert } }
        @@driver.back
      end

      def test_implicit_wait
        # checking no method error
        assert(@@driver.manage.timeouts.implicit_wait = 0)
      end

      def test_rotate
        assert_equal :portrait, @@driver.orientation

        skip_as_appium_version '1.9.0' # Error message handles over 1.9.0

        @@driver.rotation = :landscape
      end

      # TODO: add an async execuite test case
      # def test_async_execuite
      #   @@driver.execute_async_script('mobile: tap', x: 0, y: 0, element: element.id)
      #   @@driver.execute_script('mobile: tap', x: 0, y: 0, element: element.id)
      # end

      def test_logs
        assert @@driver.logs.available_types.include? :syslog
        assert @@driver.logs.get(:syslog)
      end

      # @since Appium 1.10.0
      def test_screenshot_quality
        skip_as_appium_version '1.10.0'

        lower_image_path = 'lower.png'
        lower_again_image_path = 'lower_again.png'
        higher_image_path = 'higher.png'

        File.delete lower_image_path if File.exist? lower_image_path
        File.delete lower_again_image_path if File.exist? lower_again_image_path
        File.delete higher_image_path if File.exist? higher_image_path

        # This session has `screenshotQuality: 2` capability
        @@driver.save_screenshot lower_image_path

        @@driver.update_settings({ screenshotQuality: 0 })
        @@driver.save_screenshot higher_image_path

        @@driver.update_settings({ screenshotQuality: 2 })
        @@driver.save_screenshot lower_again_image_path

        lower_image_base64 = Base64.strict_encode64(File.read(lower_image_path))
        lower_again_image_base64 = Base64.strict_encode64(File.read(lower_again_image_path))
        higher_image_base64 = Base64.strict_encode64(File.read(higher_image_path))

        assert lower_image_base64 != higher_image_base64
        assert lower_again_image_base64 != higher_image_base64

        # make sure the screenshot is png
        assert lower_image_base64.start_with?('iVBOR')
        assert lower_again_image_base64.start_with?('iVBOR')
        assert higher_image_base64.start_with?('iVBOR')
      end
    end
  end
end
# rubocop:enable Style/ClassVars
