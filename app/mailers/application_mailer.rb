# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAILER_FROM_ADDRESS", "Spase <spase@hey.nailmyjob.com>")
  layout "mailer"
end
