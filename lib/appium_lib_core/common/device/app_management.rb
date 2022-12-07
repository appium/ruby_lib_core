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
    class Base
      module Device
        module AppManagement
          def launch_app
            ::Appium::Logger.warn(
              '[DEPRECATION] launch_app is deprecated. Please use activate_app instead.'
            )
            execute :launch_app
          end

          def close_app
            ::Appium::Logger.warn(
              '[DEPRECATION] close_app is deprecated. Please use terminate_app instead.'
            )
            execute :close_app
          end

          def reset
            execute :reset
          end

          def app_strings(language = nil)
            opts = language ? { language: language } : {}
            execute :app_strings, {}, opts
          end

          def background_app(duration = 0)
            # Should override in each driver
            raise NotImplementedError
          end

          def install_app(path, options = {})
            args = { appPath: path }
            args[:options] = options unless options.empty?

            execute :install_app, {}, args
          end

          def remove_app(id, keep_data: nil, timeout: nil)
            # required: [['appId'], ['bundleId']]
            args = { appId: id }

            args[:options] = {} unless keep_data.nil? && timeout.nil?
            args[:options][:keepData] = keep_data unless keep_data.nil?
            args[:options][:timeout] = timeout unless timeout.nil?

            execute :remove_app, {}, args
          end

          def app_installed?(app_id)
            # required: [['appId'], ['bundleId']]
            execute :app_installed?, {}, bundleId: app_id
          end

          def activate_app(app_id)
            # required: [['appId'], ['bundleId']]
            execute :activate_app, {}, bundleId: app_id
          end

          def terminate_app(app_id, timeout: nil)
            # required: [['appId'], ['bundleId']]
            #
            args = { appId: app_id }

            args[:options] = {} unless timeout.nil?
            args[:options][:timeout] = timeout unless timeout.nil?

            execute :terminate_app, {}, args
          end

          private

          def options?(*args)
            args.compact.any?
          end
        end # module AppManagement
      end # module Device
    end # class Base
  end # module Core
end # module Appium
