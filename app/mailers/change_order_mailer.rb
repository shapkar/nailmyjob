# frozen_string_literal: true

class ChangeOrderMailer < ApplicationMailer
  def send_to_client(change_order)
    @change_order = change_order
    @job = change_order.job
    @client = @job.client
    @company = @job.company
    @portal_url = portal_change_order_signature_url(change_order.client_view_token)

    mail(
      to: @client.email,
      from: default_from(@company),
      subject: "Change Order ##{@change_order.co_number} from #{@company.name}"
    )
  end

  def signature_confirmation(change_order)
    @change_order = change_order
    @job = change_order.job
    @client = @job.client
    @company = @job.company

    # Send to both client and contractor
    mail(
      to: [@client.email, @company.email].compact,
      from: default_from(@company),
      subject: "Change Order ##{@change_order.co_number} Signed - #{@change_order.formatted_amount}"
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
