module Appium
  module Core
    module Device
      module AppManagement
        def self.add_methods # rubocop:disable Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
          ::Appium::Core::Device.add_endpoint_method(:launch_app) do
            def launch_app
              execute :launch_app
            end
          end

          ::Appium::Core::Device.add_endpoint_method(:close_app) do
            def close_app
              execute :close_app
            end
          end

          ::Appium::Core::Device.add_endpoint_method(:close_app) do
            def close_app
              execute :close_app
            end
          end

          ::Appium::Core::Device.add_endpoint_method(:reset) do
            def reset
              execute :reset
            end
          end

          ::Appium::Core::Device.add_endpoint_method(:app_strings) do
            def app_strings(language = nil)
              opts = language ? { language: language } : {}
              execute :app_strings, {}, opts
            end
          end

          ::Appium::Core::Device.add_endpoint_method(:background_app) do
            def background_app(duration = 0)
              execute :background_app, {}, seconds: duration
            end
          end

          ::Appium::Core::Device.add_endpoint_method(:install_app) do
            def install_app(path, # rubocop:disable Metrics/ParameterLists
                            replace: nil,
                            timeout: nil,
                            allow_test_packages: nil,
                            use_sdcard: nil,
                            grant_permissions: nil)
              args = { appPath: path }

              args[:options] = {} unless options?(replace, timeout, allow_test_packages, use_sdcard, grant_permissions)

              args[:options][:replace] = replace unless replace.nil?
              args[:options][:timeout] = timeout unless timeout.nil?
              args[:options][:allowTestPackages] = allow_test_packages unless allow_test_packages.nil?
              args[:options][:useSdcard] = use_sdcard unless use_sdcard.nil?
              args[:options][:grantPermissions] = grant_permissions unless grant_permissions.nil?

              execute :install_app, {}, args
            end

            private

            def options?(replace, timeout, allow_test_packages, use_sdcard, grant_permissions)
              replace.nil? || timeout.nil? || allow_test_packages.nil? || use_sdcard.nil? || grant_permissions.nil?
            end
          end

          ::Appium::Core::Device.add_endpoint_method(:remove_app) do
            def remove_app(id, keep_data: nil, timeout: nil)
              # required: [['appId'], ['bundleId']]
              args = { appId: id }

              args[:options] = {} unless keep_data.nil? || timeout.nil?
              args[:options][:keepData] = keep_data unless keep_data.nil?
              args[:options][:timeout] = timeout unless timeout.nil?

              execute :remove_app, {}, args
            end
          end

          ::Appium::Core::Device.add_endpoint_method(:app_installed?) do
            def app_installed?(app_id)
              # required: [['appId'], ['bundleId']]
              execute :app_installed?, {}, bundleId: app_id
            end
          end

          ::Appium::Core::Device.add_endpoint_method(:activate_app) do
            def activate_app(app_id)
              # required: [['appId'], ['bundleId']]
              execute :activate_app, {}, bundleId: app_id
            end
          end

          ::Appium::Core::Device.add_endpoint_method(:terminate_app) do
            def terminate_app(app_id, timeout: nil)
              # required: [['appId'], ['bundleId']]
              #
              args = { appId: app_id }

              args[:options] = {} unless timeout.nil?
              args[:options][:timeout] = timeout unless timeout.nil?

              execute :terminate_app, {}, args
            end
          end
        end
      end # module AppManagement
    end # module Device
  end # module Core
end # module Appium
