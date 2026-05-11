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

module Appium
  module Core
    module Device
      extend Forwardable

      class << self
        def extended(_mod)
          extend_webdriver_with_forwardable
        end

        # def extended

        # @private
        # Define method in Bridges
        def add_endpoint_method(method, &block)
          block_given? ? create_bridge_command(method, &block) : create_bridge_command(method)

          delegate_driver_method method
          delegate_from_appium_driver method
        end

        # @private CoreBridge
        def extend_webdriver_with_forwardable
          return if ::Appium::Core::Base::Driver.is_a? Forwardable

          ::Appium::Core::Base::Driver.class_eval do
            extend Forwardable
          end
        end

        private

        def delegate_from_appium_driver(method, delegation_target = :driver)
          return if ::Appium::Core::Device.method_defined? method

          def_delegator delegation_target, method
        end

        def delegate_driver_method(method)
          return if ::Appium::Core::Base::Driver.method_defined? method

          ::Appium::Core::Base::Driver.class_eval { def_delegator :@bridge, method }
        end

        def create_bridge_command(method, &block)
          ::Appium::Core::Base::Bridge.class_eval do
            undef_method method if method_defined? method
            block_given? ? class_eval(&block) : define_method(method) { execute method }
          end
        end
      end # class << self
    end
  end # module Core
end # module Appium
