module Appium
  module Core
    module Android
      module Uiautomator2
        module Bridge
          def self.for(target)
            target.extend Appium::Android::Device
            Core::Android::SearchContext.extend
            target.extend Appium::Core::Android::Uiautomator2::Device
          end
        end
      end
    end
  end
end
