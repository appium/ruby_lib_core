module Appium
  module Core
    module Device
      class ScreenRecord
        #
        # @api private
        #

        attr_reader :upload_option

        METHOD = %w(POST PUT).freeze

        def initialize(remote_path: nil, user: nil, pass: nil, method: nil, force_restart: nil)
          @upload_option = if remote_path.nil?
                             {}
                           else
                             raise 'user and pass should not be blank' if user.nil? || pass.nil?
                             raise 'method should be POST or PUT' unless METHOD.member?(method.to_s.upcase)
                             {
                               remotePath: remote_path,
                               user: user,
                               pass: pass,
                               method: method
                             }
                           end

          return if force_restart.nil?

          raise 'force_restart should be true or false' unless [true, false].member?(force_restart)
          @upload_option[:forceRestart] = force_restart
        end
      end
    end
  end
end
