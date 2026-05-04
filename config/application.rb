require_relative 'boot'

require 'rails/all'
require 'barnes'
require 'zip'


# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

ENV['RAILS_ADMIN_THEME'] = 'rollincode'

module RealEstateCrm
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2
    # OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
    config.encoding = "utf-8"

    config.exception_handler = {
      dev:        nil, # allows you to turn ExceptionHandler "on" in development
      db:         nil, # allocates a "table name" into which exceptions are saved (defaults to nil)
      email:      "admin@example.com", # sends exception emails to a listed email (string // "you@email.com")
      social: {
        facebook: ''
      },
      exceptions: {
        :all => { layout: "exception", notification: false },
        500 => { notification: true },
        501 => { notification: true },
        502 => { notification: true },
        503 => { notification: true },
        504 => { notification: true },
        505 => { notification: true },
        507 => { notification: true },
        510 => { notification: true }
      }
    }

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
  end

end
