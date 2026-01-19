# frozen_string_literal: true

class ChangeOrderPdfGeneratorJob < ApplicationJob
  queue_as :default

  def perform(change_order_id)
    change_order = ChangeOrder.find(change_order_id)

    # Generate PDF
    pdf_data = ChangeOrderPdfGenerator.new(change_order).generate

    # Attach PDF to change order
    change_order.pdf.attach(
      io: StringIO.new(pdf_data),
      filename: "CO-#{change_order.co_number}-#{change_order.quote.quote_number}.pdf",
      content_type: "application/pdf"
    )

    Rails.logger.info("Generated PDF for change order #{change_order.co_number}")
  rescue StandardError => e
    Rails.logger.error("ChangeOrderPdfGeneratorJob error: #{e.message}")
    raise
  end
end
