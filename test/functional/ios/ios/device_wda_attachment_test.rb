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

# $ rake test:func:ios TEST=test/functional/ios/ios/device_wda_attachment_test.rb
class AppiumLibCoreTest
  module Ios
    class DeviceWDAAttachmentTest < AppiumLibCoreTest::Function::TestCase
      def setup
        # will add test ad an attachment
        ios_caps = Caps.ios.dup
        ios_caps[:caps][:useNewWDA] = true
        @core = ::Appium::Core.for(ios_caps)
        @driver = @core.start_driver
      end

      def teardown
        save_reports(@driver)
      end

      def test_localhost_wda_agent_url
        status = JSON.parse(Net::HTTP.get('localhost', '/status', @core.caps[:wdaLocalPort]))['value']

        # Run with webDriverAgentUrl
        current_host = status['ios']['ip']
        current_port = @core.caps[:wdaLocalPort]

        new_ios_caps = Caps.ios.dup
        new_ios_caps[:caps][:useNewWDA] = false
        new_ios_caps[:caps][:webDriverAgentUrl] = "http://#{current_host}:#{current_port}"
        new_ios_caps[:caps].delete :wdaLocalPort
        new_ios_caps[:caps].delete :derivedDataPath
        new_ios_caps[:caps].delete :bootstrapPath
        new_ios_caps[:caps].delete :useXctestrunFile

        new_core = ::Appium::Core.for(new_ios_caps)
        @driver = new_core.start_driver
        # Make sure if the driver works
        assert @driver.remote_status

        @driver.quit
        # WDA should not stop by `quit` if `webDriverAgentUrl` exists
        assert_equal status, JSON.parse(Net::HTTP.get(current_host, '/status', current_port))['value']

        # Create the original driver again
        @driver = @core.start_driver
        status = JSON.parse(Net::HTTP.get('localhost', '/status', @core.caps[:wdaLocalPort]))['value']
        current_host = status['ios']['ip']
        current_port = @core.caps[:wdaLocalPort]

        @driver.quit

        # WDA should stop
        assert_raises(Errno::ECONNREFUSED || Errno::EINVAL) do
          JSON.parse(Net::HTTP.get(current_host, '/status', current_port))['value']
        end
      end
    end
  end
end
