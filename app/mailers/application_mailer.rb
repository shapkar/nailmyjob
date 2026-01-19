# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAILER_FROM_ADDRESS", "NailMyJob <noreply@nailmyjob.com>")
  layout "mailer"
end
