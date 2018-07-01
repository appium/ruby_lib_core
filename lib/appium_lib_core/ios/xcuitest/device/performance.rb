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
