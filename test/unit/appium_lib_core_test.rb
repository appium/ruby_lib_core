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

class AppiumLibCoreTest
  class RootTest < Minitest::Test
    def test_version
      assert !::Appium::Core::VERSION.nil?
    end

    # TODO: Should be removed in the future
    def test_symbolize_keys
      result = ::Appium.symbolize_keys({ 'a' => 1, b: 2 })
      assert_equal({ a: 1, b: 2 }, result)
    end

    def test_not_symbolize_keys_nested1
      result = ::Appium.symbolize_keys(
        { 'caps': { 'automationName' => 'xcuitest', platformName: :ios } }, nested: true
      )
      assert_equal({ caps: { automationName: 'xcuitest', platformName: :ios } }, result)
    end

    def test_not_symbolize_keys_nested2
      result = ::Appium.symbolize_keys(
        { 'caps': { 'automationName' => 'xcuitest', platformName: :ios, other_caps: { 'something1': 1, something2: 2 } } },
        nested: true
      )
      assert_equal(
        { caps: { automationName: 'xcuitest', platformName: :ios, other_caps: { 'something1': 1, something2: 2 } } },
        result
      )
    end

    def test_not_symbolize_keys_nested3
      result = ::Appium.symbolize_keys(
        { 'caps': { 'automationName' => 'xcuitest', platformName: :ios, other_caps: { 'something1': 1, something2: 2 } } },
        nested: false
      )
      assert_equal(
        { caps: { 'automationName' => 'xcuitest', platformName: :ios, other_caps: { 'something1': 1, something2: 2 } } },
        result
      )
    end

    # TODO: Should be removed in the future
    def test_symbolize_keys_raise_argument_error
      e = assert_raises ::Appium::Core::Error::ArgumentError do
        ::Appium.symbolize_keys('no hash value')
      end

      assert_equal 'symbolize_keys requires a hash', e.message
    end

    def test_core_instance_variables
      opts = {
        url: 'http://custom-host:8080/wd/hub.com',
        caps: {
          platformName: :ios,
          platformVersion: '11.0',
          deviceName: 'iPhone Simulator',
          automationName: 'XCUITest',
          app: '/path/to/MyiOS.app'
        }
      }
      @core = Appium::Core.for(opts)
      assert_equal 'http://custom-host:8080/wd/hub.com', @core.custom_url

      assert_equal :ios, @core.device
      assert_equal :xcuitest, @core.automation_name
    end

    def test_core_instance_variables_with_appium_prefix_hash
      opts = {
        url: 'http://custom-host:8080/wd/hub.com',
        caps: {
          'platformName': 'ios',
          'appium:platformVersion': '11.0',
          'appium:deviceName': 'iPhone Simulator',
          'appium:automationName': 'XCUITest',
          'appium:app': '/path/to/MyiOS.app'
        }
      }
      @core = Appium::Core.for(opts)
      assert_equal 'http://custom-host:8080/wd/hub.com', @core.custom_url

      assert_equal :ios, @core.device
      assert_equal :xcuitest, @core.automation_name
    end

    def test_core_instance_variables_with_appium_prefix_string
      opts = {
        url: 'http://custom-host:8080/wd/hub.com',
        caps: {
          'platformName' => 'ios',
          'appium:platformVersion' => '11.0',
          'appium:deviceName' => 'iPhone Simulator',
          'appium:automationName' => 'XCUITest',
          'appium:app' => '/path/to/MyiOS.app'
        }
      }
      @core = Appium::Core.for(opts)
      assert_equal 'http://custom-host:8080/wd/hub.com', @core.custom_url

      assert_equal :ios, @core.device
      assert_equal :xcuitest, @core.automation_name
    end
    def test_url_param
      opts = {
        url: 'http://custom-host:8080/wd/hub.com',
        caps: {
          platformName: :ios,
          platformVersion: '11.0',
          deviceName: 'iPhone Simulator',
          automationName: 'XCUITest',
          app: '/path/to/MyiOS.app'
        }
      }
      @core = Appium::Core.for(opts) # create a core driver with `opts` and extend methods into `self`
      assert_equal 'http://custom-host:8080/wd/hub.com', @core.custom_url
    end

    def test_url_server_url
      opts = {
        capabilities: {
          platformName: :ios,
          platformVersion: '11.0',
          deviceName: 'iPhone Simulator',
          automationName: 'XCUITest',
          app: '/path/to/MyiOS.app'
        },
        appium_lib: {
          server_url: 'http://custom-host:8080/wd/hub.com'
        }
      }
      @core = Appium::Core.for(opts) # create a core driver with `opts` and extend methods into `self`
      assert_equal 'http://custom-host:8080/wd/hub.com', @core.custom_url
    end

    def test_url_is_prior_than_server_url
      opts = {
        url: 'http://custom-host1:8080/wd/hub.com',
        caps: {
          platformName: :ios,
          platformVersion: '11.0',
          deviceName: 'iPhone Simulator',
          automationName: 'XCUITest',
          app: '/path/to/MyiOS.app'
        },
        appium_lib: {
          server_url: 'http://custom-host2:8080/wd/hub.com'
        }
      }
      @core = Appium::Core.for(opts) # create a core driver with `opts` and extend methods into `self`
      assert_equal 'http://custom-host1:8080/wd/hub.com', @core.custom_url
    end
  end
end
