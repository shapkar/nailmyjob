# frozen_string_literal: true

# Mailgun configuration for email delivery
# Set these environment variables:
#   MAILGUN_API_KEY - Your Mailgun private API key
#   MAILGUN_DOMAIN - Your Mailgun domain (e.g., mg.yourdomain.com)
#   MAILGUN_REGION - Optional: 'us' (default) or 'eu'

Rails.application.configure do
  if ENV["MAILGUN_API_KEY"].present? && ENV["MAILGUN_DOMAIN"].present?
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
      port: 587,
      address: ENV.fetch("MAILGUN_REGION", "us") == "eu" ? "smtp.eu.mailgun.org" : "smtp.mailgun.org",
      user_name: "postmaster@#{ENV['MAILGUN_DOMAIN']}",
      password: ENV["MAILGUN_SMTP_PASSWORD"] || ENV["MAILGUN_API_KEY"],
      domain: ENV["MAILGUN_DOMAIN"],
      authentication: :plain,
      enable_starttls_auto: true
    }
  end
end
