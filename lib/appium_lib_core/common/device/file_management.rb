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

require 'base64'

module Appium
  module Core
    class Base
      module Device
        module FileManagement
          def push_file(path, filedata)
            encoded_data = Base64.strict_encode64 filedata
            execute :push_file, {}, path: path, data: encoded_data
          end

          def pull_file(path)
            data = execute :pull_file, {}, path: path
            Base64.decode64 data
          end

          def pull_folder(path)
            data = execute :pull_folder, {}, path: path
            Base64.decode64 data
          end
        end # module FileManagement
      end # module Device
    end # class Base
  end # module Core
end # module Appium
