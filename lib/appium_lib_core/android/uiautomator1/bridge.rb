module Appium
  module Core
    module Android
      module Uiautomator1
        module Bridge
          def self.for(target)
            target.extend Appium::Core::Android::Device
          end
        end
      end
    end
  end
end
