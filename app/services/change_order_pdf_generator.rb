# frozen_string_literal: true

class ChangeOrderPdfGenerator
  include ActionView::Helpers::NumberHelper

  def initialize(change_order)
    @change_order = change_order
    @quote = change_order.quote
    @company = @quote.company
    @client = @quote.client
  end

  def generate
    Prawn::Document.new(page_size: "LETTER", margin: [50, 50, 50, 50]) do |pdf|
      add_header(pdf)
      add_change_order_info(pdf)
      add_description(pdf)
      add_pricing(pdf)
      add_schedule_impact(pdf)
      add_legal_boilerplate(pdf)
      add_signature_block(pdf)
      add_footer(pdf)
    end.render
  end

  private

  def add_header(pdf)
    # Company info
    pdf.text @company.name, size: 18, style: :bold, align: :right
    pdf.text @company.full_address, size: 9, align: :right if @company.full_address.present?
    pdf.text @company.phone, size: 9, align: :right if @company.phone.present?

    pdf.move_down 15
    pdf.stroke_horizontal_rule
    pdf.move_down 15

    # Title
    pdf.text "CHANGE ORDER", size: 20, style: :bold, align: :center
    pdf.text "##{@change_order.co_number}", size: 14, align: :center
    pdf.move_down 20
  end

  def add_change_order_info(pdf)
    # Two column layout
    pdf.text "Project Information", size: 12, style: :bold
    pdf.stroke_horizontal_rule
    pdf.move_down 10

    pdf.text "Client: #{@client.name}", size: 11 if @client
    pdf.text "Project: #{@quote.template_type.to_s.titleize} Remodel", size: 11
    pdf.text "Address: #{@quote.project_full_address}", size: 11 if @quote.project_full_address.present?
    pdf.text "Original Quote: #{@quote.quote_number}", size: 11
    pdf.text "Date: #{@change_order.created_at.strftime('%B %d, %Y')}", size: 11

    pdf.move_down 20
  end

  def add_description(pdf)
    pdf.text "Change Description", size: 12, style: :bold
    pdf.stroke_horizontal_rule
    pdf.move_down 10

    if @change_order.category.present?
      pdf.text "Category: #{@change_order.category.to_s.titleize}", size: 11
    end

    pdf.move_down 5
    pdf.text @change_order.description, size: 11

    pdf.move_down 20
  end

  def add_pricing(pdf)
    pdf.text "Pricing", size: 12, style: :bold
    pdf.stroke_horizontal_rule
    pdf.move_down 10

    if @change_order.is_time_and_materials && @change_order.hourly_rate.present?
      pdf.text "Time & Materials Rate: #{number_to_currency(@change_order.hourly_rate)}/hour", size: 11
      pdf.text "This change order is billed at the hourly rate above.", size: 10, color: "666666"
    else
      pdf.text "Change Order Amount: #{@change_order.formatted_amount}", size: 16, style: :bold
    end

    pdf.move_down 15

    # Show updated totals
    pdf.text "Project Total Update", size: 11, style: :bold
    pdf.text "Original Estimate: #{@quote.total_range}", size: 10
    pdf.text "Previous Changes: +#{number_to_currency(@quote.approved_changes_total - (@change_order.signed? ? @change_order.amount : 0))}", size: 10
    pdf.text "This Change: #{@change_order.formatted_amount}", size: 10

    pdf.stroke_horizontal_rule
    new_low = @quote.current_total_low + (@change_order.signed? ? 0 : @change_order.amount)
    new_high = @quote.current_total_high + (@change_order.signed? ? 0 : @change_order.amount)
    pdf.text "New Project Total: #{format_currency(new_low)} – #{format_currency(new_high)}", size: 11, style: :bold

    pdf.move_down 20
  end

  def add_schedule_impact(pdf)
    pdf.text "Schedule Impact", size: 12, style: :bold
    pdf.stroke_horizontal_rule
    pdf.move_down 10

    if @change_order.delays_schedule
      if @change_order.delay_days.present?
        pdf.text "This change delays the project by #{@change_order.delay_days} day(s).", size: 11
      else
        pdf.text "This change may impact the project schedule.", size: 11
      end
    else
      pdf.text "No schedule impact expected.", size: 11
    end

    pdf.move_down 20
  end

  def add_legal_boilerplate(pdf)
    if @change_order.legal_boilerplate.present?
      pdf.text "Terms & Authorization", size: 12, style: :bold
      pdf.stroke_horizontal_rule
      pdf.move_down 10

      pdf.text @change_order.legal_boilerplate, size: 10
      pdf.move_down 20
    end
  end

  def add_signature_block(pdf)
    if @change_order.signed?
      pdf.text "AUTHORIZED", size: 14, style: :bold, color: "00AA00"
      pdf.move_down 10

      pdf.text "Signed by: #{@change_order.signer_name}", size: 11
      pdf.text "Date: #{@change_order.signed_at.strftime('%B %d, %Y at %I:%M %p')}", size: 10

      if @change_order.signer_ip_address.present?
        pdf.text "IP Address: #{@change_order.signer_ip_address}", size: 9, color: "666666"
      end

      if @change_order.signer_geolocation.present?
        lat = @change_order.signer_geolocation["latitude"]
        lng = @change_order.signer_geolocation["longitude"]
        pdf.text "Location: #{lat}, #{lng}", size: 9, color: "666666" if lat && lng
      end
    else
      pdf.text "Authorization", size: 12, style: :bold
      pdf.move_down 15

      pdf.text "By signing below, I authorize this change to the original project scope and agree to the additional cost stated above.", size: 10
      pdf.move_down 20

      pdf.text "Client Signature:", size: 10
      pdf.stroke_horizontal_line 0, 250
      pdf.move_down 30

      pdf.text "Print Name:", size: 10
      pdf.stroke_horizontal_line 0, 200
      pdf.move_down 20

      pdf.text "Date:", size: 10
      pdf.stroke_horizontal_line 0, 150
    end
  end

  def add_footer(pdf)
    pdf.move_down 30
    pdf.text "This change order becomes part of the original contract and is subject to all original terms and conditions.",
             size: 9, color: "666666", align: :center
  end

  def format_currency(amount)
    return "$0" if amount.nil? || amount.zero?

    "$#{amount.to_i.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"
  end
end
