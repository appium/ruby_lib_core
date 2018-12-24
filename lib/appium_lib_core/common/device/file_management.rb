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
