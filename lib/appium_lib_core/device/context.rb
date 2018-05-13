module Appium
  module Core
    module Device
      module Context
        def self.add_methods
          ::Appium::Core::Device.add_endpoint_method(:within_context) do
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
          end

          ::Appium::Core::Device.add_endpoint_method(:switch_to_default_context) do
            def switch_to_default_context
              set_context nil
            end
          end

          ::Appium::Core::Device.add_endpoint_method(:current_context) do
            def current_context
              execute :current_context
            end
          end

          ::Appium::Core::Device.add_endpoint_method(:available_contexts) do
            def available_contexts
              # return empty array instead of nil on failure
              execute(:available_contexts, {}) || []
            end
          end

          ::Appium::Core::Device.add_endpoint_method(:set_context) do
            def set_context(context = null)
              execute :set_context, {}, name: context
            end
          end
        end
      end # module ImeActions
    end # module Device
  end # module Core
end # module Appium
