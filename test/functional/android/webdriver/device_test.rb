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

# $ rake test:func:android TEST=test/functional/android/webdriver/device_test.rb
# rubocop:disable Style/ClassVars
class AppiumLibCoreTest
  module WebDriver
    class DeviceTest < AppiumLibCoreTest::Function::TestCase
      def setup
        @@core ||= ::Appium::Core.for(Caps.android)
        @driver = @@core.start_driver
      end

      def teardown
        save_reports(@driver)
        @@core.quit_driver
      end

      def test_capabilities
        assert @driver.capabilities
      end

      def test_remote_status
        status = @driver.remote_status
        assert !status['build']['version'].nil?
      end

      # TODO: replace_value

      def test_set_immediate_value
        @@core.wait { @driver.find_element :accessibility_id, 'App' }.click
        @@core.wait { @driver.find_element :accessibility_id, 'Activity' }.click
        @@core.wait { @driver.find_element :accessibility_id, 'Custom Title' }.click

        e = @@core.wait { @driver.find_element :id, 'io.appium.android.apis:id/left_text_edit' }
        @driver.set_immediate_value e, 'hello'

        text = @@core.wait { @driver.find_element :id, 'io.appium.android.apis:id/left_text_edit' }
        assert_equal 'Left is besthello', text.name
      end

      def test_page_source
        require 'rexml/document'

        s_source = @driver.page_source
        xml = REXML::Document.new s_source

        assert s_source.include?('io.appium.android.apis')

        if @@core.automation_name == :espresso
          assert xml[1].elements.each('//*') { |v| v }.map(&:name).size >= 20 # rubocop:disable Lint/Void:
        else
          names = xml[2].elements.each('//*') { |v| v }.map(&:name) # rubocop:disable Lint/Void:
          assert_equal 'hierarchy', names[0]
          assert names.size >= 5
        end
      end

      def test_location
        latitude = 100
        longitude = 100
        altitude = 75
        @driver.set_location(latitude, longitude, altitude)

        @@core.wait { @driver.location } # Should we call the location once?
        loc = @@core.wait { @driver.location } # check the location
        assert_equal 100, loc.latitude
        assert_equal 100, loc.longitude
        assert_equal 75, loc.altitude
      end

      def test_accept_alert
        @@core.wait { @driver.find_element :accessibility_id, 'App' }.click
        @@core.wait { @driver.find_element :accessibility_id, 'Alert Dialogs' }.click

        @@core.wait { @driver.find_element :accessibility_id, 'OK Cancel dialog with a message' }.click

        # 'Could not proxy. Proxy error: Could not proxy command to remote server. Original error: 404 - ""'
        # assert @driver.switch_to.alert.text.start_with?('Lorem ipsum dolor sit aie consectetur')
        # assert @driver.switch_to.alert.dismiss
        @@core.wait { assert_equal 'OK', @driver.find_element(:id, 'android:id/button1').text.upcase }
        result = @driver.find_element(:id, 'android:id/button1').click
        assert result.nil? || result
      end

      def test_dismiss_alert
        @@core.wait { @driver.find_element :accessibility_id, 'App' }.click
        @@core.wait { @driver.find_element :accessibility_id, 'Alert Dialogs' }.click

        @@core.wait { @driver.find_element :accessibility_id, 'OK Cancel dialog with a message' }.click

        # 'Could not proxy. Proxy error: Could not proxy command to remote server. Original error: 404 - ""'
        # assert @driver.switch_to.alert.text.start_with?('Lorem ipsum dolor sit aie consectetur')
        # assert @driver.switch_to.alert.dismiss

        # Because the results depends on OS version.
        @@core.wait { assert_equal 'CANCEL', @driver.find_element(:id, 'android:id/button2').text.upcase }
        result = @driver.find_element(:id, 'android:id/button2').click
        assert result.nil? || result
      end

      def test_implicit_wait
        # checking no method error
        assert(@driver.manage.timeouts.implicit_wait = @@core.default_wait)
      end

      def test_rotate
        assert_equal :portrait, @driver.orientation

        @driver.rotation = :landscape
        assert_equal :landscape, @driver.orientation

        @driver.rotation = :portrait
        assert_equal :portrait, @driver.orientation
      end

      def test_logs
        # :logcat, :bugreport, :server in 1.7.2
        assert_equal %i(logcat bugreport server), @driver.logs.available_types
        assert @driver.logs.get(:logcat)
      end

      def test_network_connection
        assert @driver.get_network_connection
        assert @driver.network_connection_type
        assert @driver.set_network_connection(6)
        # TODO: depends on selenium-webdriver. Test failed with webdriver 3.11.0 with a number.
        assert @driver.network_connection_type = :all
      end

      def test_session_capability
        assert @driver.session_capabilities['deviceUDID'].start_with? 'emulator-'
      end
    end
  end
end
# rubocop:enable Style/ClassVars
