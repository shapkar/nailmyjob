# frozen_string_literal: true

class QuotePdfGenerator
  include ActionView::Helpers::NumberHelper

  def initialize(quote)
    @quote = quote
    @company = quote.company
    @client = quote.client
  end

  def generate
    Prawn::Document.new(page_size: "LETTER", margin: [50, 50, 50, 50]) do |pdf|
      add_header(pdf)
      add_client_info(pdf)
      add_project_info(pdf)
      add_line_items(pdf)
      add_totals(pdf)
      add_terms(pdf)
      add_signature_block(pdf)
      add_footer(pdf)
    end.render
  end

  private

  def add_header(pdf)
    # Company logo and name
    if @company.logo.attached?
      begin
        logo_path = ActiveStorage::Blob.service.path_for(@company.logo.key)
        pdf.image logo_path, width: 100, position: :left
      rescue StandardError
        # Skip logo if not available
      end
    end

    pdf.text @company.name, size: 24, style: :bold, align: :right
    pdf.text @company.full_address, size: 10, align: :right if @company.full_address.present?
    pdf.text @company.phone, size: 10, align: :right if @company.phone.present?
    pdf.text @company.email, size: 10, align: :right if @company.email.present?

    if @company.license_number.present?
      pdf.text "License ##{@company.license_number}", size: 10, align: :right
    end

    pdf.move_down 20
    pdf.stroke_horizontal_rule
    pdf.move_down 20

    # Title
    pdf.text "PRELIMINARY PROJECT ESTIMATE", size: 18, style: :bold, align: :center
    pdf.move_down 20
  end

  def add_client_info(pdf)
    pdf.text "Prepared for:", size: 10, style: :bold
    pdf.text @client.name, size: 12 if @client
    pdf.text @client.full_address, size: 10 if @client&.full_address.present?

    pdf.move_down 10
    pdf.text "Quote Number: #{@quote.quote_number}", size: 10
    pdf.text "Date: #{@quote.created_at.strftime('%B %d, %Y')}", size: 10
    pdf.text "Valid for: #{@quote.valid_days} days", size: 10 if @quote.valid_days

    pdf.move_down 20
  end

  def add_project_info(pdf)
    pdf.text "Project Details", size: 14, style: :bold
    pdf.stroke_horizontal_rule
    pdf.move_down 10

    pdf.text "Project Type: #{@quote.template_type.to_s.titleize} Remodel", size: 11
    pdf.text "Project Size: #{@quote.project_size.to_s.titleize}", size: 11

    if @quote.project_full_address.present?
      pdf.text "Project Address: #{@quote.project_full_address}", size: 11
    end

    if @quote.timeline_estimate.present?
      pdf.text "Estimated Timeline: #{@quote.timeline_estimate}", size: 11
    end

    pdf.move_down 20
  end

  def add_line_items(pdf)
    pdf.text "Estimated Budget Ranges", size: 14, style: :bold
    pdf.move_down 5
    pdf.text "Final pricing will be confirmed after material selections are made.", size: 9, color: "666666"
    pdf.stroke_horizontal_rule
    pdf.move_down 15

    # Materials section
    material_items = @quote.line_items.materials
    if material_items.any?
      pdf.text "MATERIALS", size: 12, style: :bold
      pdf.move_down 10

      material_items.each do |item|
        add_line_item_row(pdf, item)
      end

      pdf.move_down 15
    end

    # Labor section
    labor_items = @quote.line_items.labor
    if labor_items.any?
      pdf.text "LABOR & PROJECT COSTS", size: 12, style: :bold
      pdf.move_down 10

      labor_items.each do |item|
        add_line_item_row(pdf, item)
      end

      pdf.move_down 15
    end

    # Other items
    other_items = @quote.line_items.where(category: :other)
    if other_items.any?
      pdf.text "OTHER", size: 12, style: :bold
      pdf.move_down 10

      other_items.each do |item|
        add_line_item_row(pdf, item)
      end

      pdf.move_down 15
    end
  end

  def add_line_item_row(pdf, item)
    allowance_marker = item.is_allowance ? " *" : ""

    pdf.text "#{item.description}#{allowance_marker}", size: 11, style: :bold
    pdf.text item.range_display, size: 11, align: :right
    pdf.move_down 8
  end

  def add_totals(pdf)
    pdf.stroke_horizontal_rule
    pdf.move_down 15

    pdf.text "ESTIMATED PROJECT TOTAL", size: 14, style: :bold
    pdf.text @quote.total_range, size: 18, style: :bold

    pdf.move_down 10
    pdf.text "* Items marked with asterisk (*) are Estimated Budget Ranges subject to final material selection.",
             size: 9, color: "666666"

    if @quote.approved_changes_total&.positive?
      pdf.move_down 10
      pdf.text "Approved Change Orders: +#{number_to_currency(@quote.approved_changes_total)}", size: 11
      pdf.text "Current Project Total: #{@quote.current_total_range}", size: 12, style: :bold
    end

    pdf.move_down 20
  end

  def add_terms(pdf)
    if @quote.notes.present?
      pdf.text "Project Notes", size: 12, style: :bold
      pdf.text @quote.notes, size: 10
      pdf.move_down 15
    end

    if @quote.payment_terms.present?
      pdf.text "Payment Terms", size: 12, style: :bold
      pdf.text @quote.payment_terms, size: 10
      pdf.move_down 15
    end

    if @quote.terms.present?
      pdf.text "Terms & Conditions", size: 12, style: :bold
      pdf.text @quote.terms, size: 9
      pdf.move_down 15
    end
  end

  def add_signature_block(pdf)
    pdf.move_down 20

    if @quote.signed?
      pdf.text "SIGNED", size: 14, style: :bold, color: "00AA00"

      if @quote.signature_data["signature_image"].present?
        # Add signature image if available
        pdf.text "Signature on file", size: 10
      end

      signed_at = Time.parse(@quote.signature_data["signed_at"]) rescue @quote.signed_at
      pdf.text "Signed: #{signed_at.strftime('%B %d, %Y at %I:%M %p')}", size: 10
    else
      pdf.text "Customer Signature", size: 10
      pdf.move_down 5
      pdf.stroke_horizontal_line 0, 250
      pdf.move_down 30

      pdf.text "Date", size: 10
      pdf.stroke_horizontal_line 0, 150
    end
  end

  def add_footer(pdf)
    pdf.move_down 30
    pdf.text "This is a preliminary estimate for planning purposes. A detailed contract will be provided upon acceptance.",
             size: 9, color: "666666", align: :center

    if @company.phone.present?
      pdf.move_down 10
      pdf.text "Questions? Call #{@company.phone}", size: 10, align: :center
    end
  end
end
