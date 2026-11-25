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

# $ rake test:func:ios TEST=test/functional/ios/ios/device_wda_attachment_test.rb
class AppiumLibCoreTest
  module Ios
    class DeviceWDAAttachmentTest < AppiumLibCoreTest::Function::TestCase
      def teardown
        save_reports(@driver) if @driver
      ensure
        @driver&.quit
      end

      def test_localhost_wda_agent_url
        opts = Caps.ios
        caps = opts.fetch(:caps)
        status_url = URI("http://localhost:#{caps.fetch(:wdaLocalPort)}/status")

        # An xcodebuild-managed WDA can stay running after its Appium session quits.
        reusable_caps = caps.except(:usePreinstalledWDA, :prebuiltWDAPath).merge(useNewWDA: false)
        @driver = ::Appium::Core.for(opts.merge(caps: reusable_caps)).start_driver
        @driver.quit
        @driver = nil
        assert JSON.parse(Net::HTTP.get(status_url)).fetch('value').fetch('ready')

        attach_caps = reusable_caps.merge(webDriverAgentUrl: "http://localhost:#{status_url.port}")
        @driver = ::Appium::Core.for(opts.merge(caps: attach_caps)).start_driver
        assert @driver.window_rect.width.positive?
        @driver.quit
        @driver = nil
        assert JSON.parse(Net::HTTP.get(status_url)).fetch('value').fetch('ready')

        # A fresh, driver-owned WDA should stop when its session quits.
        core = ::Appium::Core.for(opts.merge(caps: caps.merge(useNewWDA: true)))
        @driver = core.start_driver
        assert JSON.parse(Net::HTTP.get(status_url)).fetch('value').fetch('ready')
        @driver.quit
        @driver = nil
        core.wait_true do
          Net::HTTP.get(status_url)
          false
        rescue Errno::ECONNREFUSED
          true
        end
      end
    end
  end
end
