module Appium
  module Core
    module Ios
      module Uiautomation
        module Bridge
          def self.for(target)
            target.extend Appium::Core::Ios::Device

            Core::Ios::Uiautomation.patch_webdriver_element
          end
        end
      end
    end
  end
end
