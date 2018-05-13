module Appium
  module Core
    module Device
      class ScreenRecord
        #
        # @api private
        #

        attr_reader :upload_option

        METHOD = %w(POST PUT).freeze

        def self.add_methods
          ::Appium::Core::Device.add_endpoint_method(:stop_recording_screen) do
            def stop_recording_screen(remote_path: nil, user: nil, pass: nil, method: 'PUT')
              option = ::Appium::Core::Device::ScreenRecord.new(
                remote_path: remote_path, user: user, pass: pass, method: method
              ).upload_option

              params = option.empty? ? {} : { options: option }

              execute(:stop_recording_screen, {}, params)
            end
          end

          ::Appium::Core::Device.add_endpoint_method(:stop_and_save_recording_screen) do
            def stop_and_save_recording_screen(file_path)
              base64data = execute(:stop_recording_screen, {}, {})
              File.open(file_path, 'wb') { |f| f << Base64.decode64(base64data) }
            end
          end
        end

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
      end
    end
  end
end
