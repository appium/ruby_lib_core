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
        class ScreenRecord
          #
          # @api private
          #

          attr_reader :upload_option

          METHOD = %w(POST PUT).freeze

          def initialize(remote_path: nil, user: nil, pass: nil, method: 'PUT', force_restart: nil)
            @upload_option = if remote_path.nil?
                               {}
                             else
                               raise 'method should be POST or PUT' unless METHOD.member?(method.to_s.upcase)

                               option = {}
                               option[:remotePath] = remote_path
                               option[:user] = user unless user.nil?
                               option[:pass] = pass unless pass.nil?
                               option[:method] = method
                               option
                             end

            return if force_restart.nil?

            raise 'force_restart should be true or false' unless [true, false].member?(force_restart)

            @upload_option[:forceRestart] = force_restart
          end

          module Command
            def stop_recording_screen(remote_path: nil, user: nil, pass: nil, method: 'PUT')
              option = ::Appium::Core::Base::Device::ScreenRecord.new(
                remote_path: remote_path, user: user, pass: pass, method: method
              ).upload_option

              params = option.empty? ? {} : { options: option }

              execute(:stop_recording_screen, {}, params)
            end

            def stop_and_save_recording_screen(file_path)
              base64data = execute(:stop_recording_screen, {}, {})
              File.open(file_path, 'wb') { |f| f << Base64.decode64(base64data) }
            end
          end # module Command
        end # class ScreenRecord
      end # module Device
    end # class Base
  end # module Core
end # module Appium
