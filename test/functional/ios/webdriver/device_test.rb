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

      # TODO: replave_value

      def test_set_immediate_value
        w3c_scroll @@driver

        @@core.wait { @@driver.find_element :accessibility_id, 'Text Fields' }.click

        e = @@core.wait { @@driver.find_element :name, 'Placeholder text' }
        e.click
        @@driver.set_immediate_value e, 'hello'

        # Using predicate case
        e = @@core.wait { @@driver.find_element :predicate, by_predicate('hello') }
        assert_equal 'hello', e.value

        @@driver.back
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

        latitude = 100
        longitude = 100
        altitude = 75
        @@driver.set_location(latitude, longitude, altitude)

        error = assert_raises ::Selenium::WebDriver::Error::UnknownMethodError do
          @@driver.location
        end
        assert error.message.include? 'Method has not yet been implemented'
      end

      def test_accept_alert
        @@core.wait { @@driver.find_element :accessibility_id, 'Alert Views' }.click
        @@core.wait { @@driver.find_element :accessibility_id, 'Okay / Cancel' }.click

        @@core.wait { assert @@driver.switch_to.alert.text.start_with?('A Short Title Is Best') }
        assert @@driver.switch_to.alert.accept

        @@driver.back
      end

      # NOTE: Sometimes this test fails because of getting nil in @@driver.switch_to.alert.text
      def test_dismiss_alert
        @@core.wait { @@driver.find_element :accessibility_id, 'Alert Views' }.click
        @@core.wait { @@driver.find_element :accessibility_id, 'Okay / Cancel' }.click

        @@core.wait { assert @@driver.switch_to.alert.text.start_with?('A Short Title Is Best') }
        assert @@driver.switch_to.alert.dismiss

        @@driver.back
      end

      def test_implicit_wait
        # checking no method error
        assert(@@driver.manage.timeouts.implicit_wait = @@core.default_wait)
      end

      def test_rotate
        assert_equal :portrait, @@driver.orientation

        skip_as_appium_version '1.9.0' # Error message handles over 1.9.0

        @@driver.rotation = :landscape
      end

      # TODO: add an async execuite test case
      # def test_async_execuite
      #   @@driver.execute_async_script('mobile: tap', x: 0, y: 0, element: element.ref)
      #   @@driver.execute_script('mobile: tap', x: 0, y: 0, element: element.ref)
      # end

      def test_logs
        assert @@driver.logs.available_types.include? :syslog
        assert @@driver.logs.get(:syslog)
      end

      def test_session_capability
        assert !@@driver.session_capabilities['udid'].nil?
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
