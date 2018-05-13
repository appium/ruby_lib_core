require 'base64'

module Appium
  module Core
    module Device
      module FileManagement
        def self.add_methods
          Appium::Core::Device.add_endpoint_method(:push_file) do
            def push_file(path, filedata)
              encoded_data = Base64.encode64 filedata
              execute :push_file, {}, path: path, data: encoded_data
            end
          end

          Appium::Core::Device.add_endpoint_method(:pull_file) do
            def pull_file(path)
              data = execute :pull_file, {}, path: path
              Base64.decode64 data
            end
          end

          Appium::Core::Device.add_endpoint_method(:pull_folder) do
            def pull_folder(path)
              data = execute :pull_folder, {}, path: path
              Base64.decode64 data
            end
          end
        end
      end # module FileManagement
    end # module Device
  end # module Core
end # module Appium
