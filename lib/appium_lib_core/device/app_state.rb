module Appium
  module Core
    module Device
      class AppState
        STATUS = [
          :not_installed,                   # 0
          :not_running,                     # 1
          :running_in_background_suspended, # 2
          :running_in_background,           # 3
          :running_in_foreground            # 4
        ].freeze
      end
    end
  end
end
