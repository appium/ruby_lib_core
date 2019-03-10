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
    module Ios
      module Xcuitest
        module Device
          module Performance
            def self.add_methods
              ::Appium::Core::Device.add_endpoint_method(:start_performance_record) do
                def start_performance_record(timeout: 300_000, profile_name: 'Activity Monitor', pid: nil)
                  option = {}
                  option[:timeout] = timeout
                  option[:profileName] = profile_name
                  option[:pid] = pid if pid

                  execute_script 'mobile: startPerfRecord', option
                end
              end

              ::Appium::Core::Device.add_endpoint_method(:get_performance_record) do
                def get_performance_record(save_file_path: './performance', profile_name: 'Activity Monitor',
                                           remote_path: nil, user: nil, pass: nil, method: 'PUT')
                  option = ::Appium::Core::Base::Device::ScreenRecord.new(
                    remote_path: remote_path, user: user, pass: pass, method: method
                  ).upload_option

                  option[:profileName] = profile_name
                  result = execute_script 'mobile: stopPerfRecord', option

                  File.open("#{save_file_path}.zip", 'wb') { |f| f << result.unpack('m')[0] }
                end
              end
            end
          end # module Performance
        end # module Device
      end # module Xcuitest
    end # module Ios
  end # module Core
end # module Appium
