module Appium
  module Core
    class Base
      module Device
        module Context
          def within_context(context)
            existing_context = current_context
            set_context context
            if block_given?
              result = yield
              set_context existing_context
              result
            else
              set_context existing_context
            end
          end

          def switch_to_default_context
            set_context nil
          end

          def current_context
            execute :current_context
          end

          def available_contexts
            # return empty array instead of nil on failure
            execute(:available_contexts, {}) || []
          end

          def set_context(context = null)
            execute :set_context, {}, name: context
          end
        end # module ImeActions
      end # module Device
    end # class Base
  end # module Core
end # module Appium
