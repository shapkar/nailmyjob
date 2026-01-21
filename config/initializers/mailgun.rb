# frozen_string_literal: true

# Mailgun configuration for email delivery using the Mailgun API
# This is the recommended method by Mailgun (faster and more reliable than SMTP)
#
# Set these environment variables:
#   MAILGUN_API_KEY - Your Mailgun private API key (starts with "key-" or is a long string)
#   MAILGUN_DOMAIN - Your Mailgun sending domain (e.g., hey.nailmyjob.com)
#   MAILGUN_REGION - Optional: 'us' (default) or 'eu'

require "mailgun-ruby"

Rails.application.configure do
  if ENV["MAILGUN_API_KEY"].present? && ENV["MAILGUN_DOMAIN"].present?
    # Use Mailgun API for delivery (recommended over SMTP)
    config.action_mailer.delivery_method = :mailgun
    config.action_mailer.mailgun_settings = {
      api_key: ENV["MAILGUN_API_KEY"],
      domain: ENV["MAILGUN_DOMAIN"],
      # Use EU endpoint if region is 'eu', otherwise use US (default)
      api_host: ENV.fetch("MAILGUN_REGION", "us") == "eu" ? "api.eu.mailgun.net" : "api.mailgun.net"
    }
  end
end
