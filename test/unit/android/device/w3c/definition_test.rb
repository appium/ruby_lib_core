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

# $ rake test:unit TEST=test/unit/android/device/w3c/definition_test.rb
class AppiumLibCoreTest
  module Android
    module Device
      module W3C
        class DefinitionTest < Minitest::Test
          include AppiumLibCoreTest::Mock

          def setup
            @core ||= ::Appium::Core.for(Caps.android)
            @driver ||= android_mock_create_session_w3c
          end

          def test_delegate_driver_method
            assert @driver.respond_to? :device_locked?
          end

          def delegate_from_appium_driver(key)
            assert @core.send(:delegated_target_for_test).respond_to?(key), "#{key} was wrong"
          end

          def parameterized_method_defined_check(array)
            array.each do |v|
              assert ::Appium::Core::Base::Bridge.method_defined?(v), "#{v} was wrong"
              delegate_from_appium_driver(v)
            end
          end
        end # class DefinitionTest
      end # module W3C
    end # module Device
  end # module Android
end # class AppiumLibCoreTest
