module Appium
  module Core
    module Ios
      module Xcuitest
        module Device
          module Screen
            def self.add_methods
              ::Appium::Core::Device.add_endpoint_method(:start_recording_screen) do
                # rubocop:disable Metrics/ParameterLists
                def start_recording_screen(remote_path: nil, user: nil, pass: nil, method: 'PUT', force_restart: nil,
                                           video_type: 'mjpeg', time_limit: '180', video_quality: 'medium',
                                           video_fps: nil, video_scale: nil)
                  option = ::Appium::Core::Base::Device::ScreenRecord.new(
                    remote_path: remote_path, user: user, pass: pass, method: method, force_restart: force_restart
                  ).upload_option

                  option[:videoType] = video_type
                  option[:timeLimit] = time_limit
                  option[:videoQuality] = video_quality

                  option[:videoFps] = video_fps unless video_fps.nil?
                  option[:videoScale] = video_scale unless video_scale.nil?

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
