module Appium
  module Core
    module Android
      module Device
        module Screen
          def self.add_methods
            ::Appium::Core::Device.add_endpoint_method(:get_display_density) do
              def get_display_density
                execute :get_display_density
              end
            end

            ::Appium::Core::Device.add_endpoint_method(:start_recording_screen) do
              # rubocop:disable Metrics/ParameterLists
              def start_recording_screen(remote_path: nil, user: nil, pass: nil, method: 'PUT', force_restart: nil,
                                         video_size: nil, time_limit: '180', bit_rate: nil, bug_report: nil)
                option = ::Appium::Core::Base::Device::ScreenRecord.new(
                  remote_path: remote_path, user: user, pass: pass, method: method, force_restart: force_restart
                ).upload_option

                option[:videoSize] = video_size unless video_size.nil?
                option[:timeLimit] = time_limit
                option[:bitRate] = bit_rate unless bit_rate.nil?

                unless bug_report.nil?
                  raise 'bug_report should be true or false' unless [true, false].member?(bug_report)

                  option[:bugReport] = bug_report
                end

                execute(:start_recording_screen, {}, { options: option })
              end
              # rubocop:enable Metrics/ParameterLists
            end
          end
        end # module Screen
      end # module Device
    end # module Android
  end # module Core
end # module Appium
