module Appium
  module Core
    module Device
      class ScreenRecord
        #
        # @api private
        #

        attr_reader :upload_option

        METHOD = %w(POST PUT).freeze

        def initialize(remote_path: nil, user: nil, password: nil, method: 'PUT', force_restart: nil)
          @upload_option = if remote_path.nil?
                             {}
                           else
                             raise 'method should be POST or PUT' unless METHOD.member?(method.to_s.upcase)

                             option = {}
                             option[:remotePath] = remote_path
                             option[:user] = user unless user.nil?
                             option[:pass] = password unless password.nil?
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
