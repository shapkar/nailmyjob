# frozen_string_literal: true

class QuotePdfGeneratorJob < ApplicationJob
  queue_as :default

  def perform(quote_id)
    quote = Quote.find(quote_id)

    # Generate PDF
    pdf_data = QuotePdfGenerator.new(quote).generate

    # Attach PDF to quote
    quote.pdf.attach(
      io: StringIO.new(pdf_data),
      filename: "#{quote.quote_number}.pdf",
      content_type: "application/pdf"
    )

    Rails.logger.info("Generated PDF for quote #{quote.quote_number}")
  rescue StandardError => e
    Rails.logger.error("QuotePdfGeneratorJob error: #{e.message}")
    raise
  end
end
