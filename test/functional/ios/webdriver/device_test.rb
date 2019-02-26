require 'test_helper'

# $ rake test:func:ios TEST=test/functional/ios/webdriver/device_test.rb
# rubocop:disable Style/ClassVars
class AppiumLibCoreTest
  module WebDriver
    class DeviceTest < AppiumLibCoreTest::Function::TestCase
      def setup
        @@core ||= ::Appium::Core.for(Caps.ios)
        @@driver ||= @@core.start_driver
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
        @@core.wait { @@driver.find_element :accessibility_id, 'TextFields' }.click

        e = @@core.wait { @@driver.find_element :name, '<enter text>' }
        e.click
        @@driver.set_immediate_value e, 'hello'

        # Using predicate case
        e = @@core.wait { @@driver.find_element :predicate, by_predicate('hello') }
        assert_equal 'Normal', e.name
        assert_equal 'hello', e.value

        @@driver.back
      end

      def by_predicate(value)
        %(name ==[c] "#{value}" || label ==[c] "#{value}" || value ==[c] "#{value}")
      end

      def test_page_source
        require 'json'
        require 'rexml/document'

        response = Net::HTTP.get(URI("http://localhost:#{@@driver.capabilities['wdaLocalPort']}/source"))
        source = JSON.parse(response)['value']
        xml = REXML::Document.new source

        assert !source.include?('AppiumAUT')
        assert source.include?('XCUIElementTypeApplication type')
        assert_in_delta 80, xml[2].elements.each('//*') { |v| v }.map(&:name).size, 5 # rubocop:disable Lint/Void:

        s_source = @@driver.page_source
        s_xml = REXML::Document.new s_source

        assert s_source.include?('AppiumAUT')
        assert s_source.include?('XCUIElementTypeApplication type')

        assert [78, 81].include?(s_xml[2].elements.each('//*') { |v| v }.map(&:name).size) # rubocop:disable Lint/Void:
      end

      def test_location
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
        @@core.wait { @@driver.find_element :accessibility_id, 'Alerts' }.click
        @@core.wait { @@driver.find_element :accessibility_id, 'Show OK-Cancel' }.click

        @@core.wait { assert_equal 'UIActionSheet <title>', @@driver.switch_to.alert.text }
        assert @@driver.switch_to.alert.accept

        @@driver.back
      end

      # NOTE: Sometimes this test fails because of getting nil in @@driver.switch_to.alert.text
      def test_dismiss_alert
        @@core.wait { @@driver.find_element :accessibility_id, 'Alerts' }.click
        @@core.wait { @@driver.find_element :accessibility_id, 'Show OK-Cancel' }.click

        @@core.wait { assert_equal 'UIActionSheet <title>', @@driver.switch_to.alert.text }
        assert @@driver.switch_to.alert.dismiss

        @@driver.back
      end

      def test_implicit_wait
        # checking no method error
        assert(@@driver.manage.timeouts.implicit_wait = @@core.default_wait)
      end

      def test_rotate
        assert_equal :portrait, @@driver.orientation

        error = assert_raises ::Selenium::WebDriver::Error::UnknownError do
          @@driver.rotation = :landscape
        end
        assert error.message.include? 'Unable To Rotate Device'
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

        assert File.size(lower_image_path) != File.size(higher_image_path)
        assert_equal File.size(lower_again_image_path), File.size(lower_image_path)

        # make sure the screenshot is png
        assert Base64.strict_encode64(File.read(lower_image_path)).start_with?('iVBOR')
        assert Base64.strict_encode64(File.read(higher_image_path)).start_with?('iVBOR')
      end
    end
  end
end
# rubocop:enable Style/ClassVars
