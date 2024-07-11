require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module TruWell
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w(assets tasks))

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true
    config.active_job.queue_adapter = :sidekiq

    config.action_cable.mount_path = '/cable'
    config.action_cable.url = "ws://192.168.0.115:3000/cable"


    config.action_cable.allowed_request_origins = [/^(http|https)\:\/\/(?:\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}|localhost):\d{1,5}$/]
    #   # 'http://yourdomain.com',
    #   # 'https://yourdomain.com',
    #   # 'http://localhost:3000',
    #   # 'http://localhost:3001',
    #   # 'http://192.168.0.115:3000'
    #   # 'http://localhost:3000'
    #   'http:\/\/localhost:\d+'



    # ]

    # config.action_cable.allowed_request_origins = [ 'http://localhost:3000', /http:\/\/192\.168\.0\.\d+:\d+/]
    # config.active_record.default_timezone = :local

    config.time_zone = 'Kolkata'

    # config.middleware.insert_before 0, Rack::Cors do
    #   allow do
    #     origins '*'
    #     resource '*', headers: :any, methods: [:get, :post, :patch, :delete]
    #   end
    # end

  end
end


# /http:\/\/(localhost|127\.0\.0\.1|\[::1\])(:\d+)?/

# [/http:\/\/(localhost|127\.0\.0\.1|\[::1\])(:\d+)?/]