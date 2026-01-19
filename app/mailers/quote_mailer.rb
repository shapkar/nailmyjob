# frozen_string_literal: true

class QuoteMailer < ApplicationMailer
  def send_to_client(quote)
    @quote = quote
    @client = quote.client
    @company = quote.company
    @portal_url = portal_quote_url(quote.client_view_token)

    mail(
      to: @client.email,
      from: default_from(@company),
      subject: "New Quote from #{@company.name} - #{@quote.template_type.to_s.titleize} Remodel"
    )
  end

  def signature_confirmation(quote)
    @quote = quote
    @client = quote.client
    @company = quote.company

    # Send to both client and contractor
    mail(
      to: [@client.email, @company.email].compact,
      from: default_from(@company),
      subject: "Quote Signed - #{@quote.quote_number}"
    )
  end

  def quote_viewed(quote)
    @quote = quote
    @company = quote.company
    @contractor_email = quote.user.email

    mail(
      to: @contractor_email,
      from: default_from(@company),
      subject: "#{quote.client.name} viewed your quote"
    )
  end

  private

  def default_from(company)
    if company.email.present?
      "#{company.name} <#{company.email}>"
    else
      "NailMyJob <noreply@nailmyjob.com>"
    end
  end
end
