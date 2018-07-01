module Appium
  module Core
    module Ios
      module Xcuitest
        module Device
          module Screen
            def self.add_methods
              ::Appium::Core::Device.add_endpoint_method(:start_recording_screen) do
                # rubocop:disable Metrics/ParameterLists
                def start_recording_screen(remote_path: nil, user: nil, pass: nil, method: nil, force_restart: nil,
                                           video_type: 'mp4', time_limit: '180', video_quality: 'medium')
                  option = ::Appium::Core::Base::Device::ScreenRecord.new(
                    remote_path: remote_path, user: user, pass: pass, method: method, force_restart: force_restart
                  ).upload_option

                  option[:videoType] = video_type
                  option[:timeLimit] = time_limit
                  option[:videoQuality] = video_quality

                  execute(:start_recording_screen, {}, { options: option })
                end
                # rubocop:enable Metrics/ParameterLists
              end
            end
          end # module Screen
        end # module Device
      end # module Xcuitest
    end # module Ios
  end # module Core
end # module Appium
