# frozen_string_literal: true

class QuotesController < ApplicationController
  before_action :require_company!
  before_action :set_quote, only: [:show, :edit, :update, :destroy, :send_to_client, :duplicate, :preview_pdf, :download_pdf]
  before_action :load_templates, only: [:new, :create]

  def index
    @pagy, @quotes = pagy(
      current_company.quotes
                     .includes(:client, :line_items, job: :change_orders)
                     .recent,
      items: 20
    )

    # Filter by status if provided
    @quotes = @quotes.by_status(params[:status]) if params[:status].present?
  end

  def show
    @line_items = @quote.line_items
  end

  def new
    @quote = current_company.quotes.build(
      user: current_user,
      template_type: params[:template_type] || :kitchen,
      project_size: :medium,
      valid_days: 30,
      terms: current_company.default_terms,
      payment_terms: current_company.default_payment_terms
    )

    # Pre-populate line items from template
    if params[:template_id].present?
      template = QuoteTemplate.for_company(current_company).find(params[:template_id])
      template.build_line_items_for_quote(@quote)
    elsif @quote.template_type.present?
      template = QuoteTemplate.system_templates.find_by(template_type: @quote.template_type)
      template&.build_line_items_for_quote(@quote)
    end
  end

  def create
    @quote = current_company.quotes.build(quote_params)
    @quote.user = current_user

    # Build or find client
    if params[:quote][:client_id].present?
      @quote.client = current_company.clients.find(params[:quote][:client_id])
    elsif params[:quote][:client_attributes].present?
      @quote.build_client(
        company: current_company,
        **params[:quote][:client_attributes].permit(:name, :email, :phone, :address, :city, :state, :zip_code)
      )
    end

    # Apply template if needed
    if @quote.line_items.empty? && params[:template_id].present?
      template = QuoteTemplate.for_company(current_company).find(params[:template_id])
      template.build_line_items_for_quote(@quote)
    elsif @quote.line_items.empty?
      template = QuoteTemplate.system_templates.find_by(template_type: @quote.template_type)
      template&.build_line_items_for_quote(@quote)
    end

    if @quote.save
      respond_to do |format|
        format.html { redirect_to edit_quote_path(@quote), notice: "Quote created. Now customize the details." }
        format.turbo_stream { redirect_to edit_quote_path(@quote), notice: "Quote created." }
      end
    else
      load_templates
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @line_items = @quote.line_items
    @clients = current_company.clients.recent.limit(50)
  end

  def update
    if @quote.update(quote_params)
      respond_to do |format|
        format.html { redirect_to @quote, notice: "Quote updated successfully." }
        format.turbo_stream { flash.now[:notice] = "Quote updated." }
      end
    else
      @line_items = @quote.line_items
      @clients = current_company.clients.recent.limit(50)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @quote.destroy

    respond_to do |format|
      format.html { redirect_to quotes_path, notice: "Quote deleted." }
      format.turbo_stream { flash.now[:notice] = "Quote deleted." }
    end
  end

  def send_to_client
    if @quote.client.blank?
      redirect_to edit_quote_path(@quote), alert: "Please add client information first."
      return
    end

    if @quote.client.email.blank?
      redirect_to edit_quote_path(@quote), alert: "Please add client email address first."
      return
    end

    # Generate PDF (in background)
    QuotePdfGeneratorJob.perform_later(@quote.id)

    # Send email via Mailgun
    QuoteMailer.send_to_client(@quote).deliver_later
    @quote.mark_as_sent!

    respond_to do |format|
      format.html { redirect_to @quote, notice: "Quote sent to #{@quote.client.name} at #{@quote.client.email}." }
      format.turbo_stream { flash.now[:notice] = "Quote sent to #{@quote.client.name}." }
    end
  end

  def duplicate
    new_quote = @quote.duplicate!

    respond_to do |format|
      format.html { redirect_to edit_quote_path(new_quote), notice: "Quote duplicated." }
      format.turbo_stream { redirect_to edit_quote_path(new_quote) }
    end
  end

  def preview_pdf
    pdf = QuotePdfGenerator.new(@quote).generate
    send_data pdf, filename: "#{@quote.quote_number}.pdf", type: "application/pdf", disposition: "inline"
  end

  def download_pdf
    pdf = QuotePdfGenerator.new(@quote).generate
    send_data pdf, filename: "#{@quote.quote_number}.pdf", type: "application/pdf", disposition: "attachment"
  end

  private

  def set_quote
    @quote = current_company.quotes.find(params[:id])
  end

  def load_templates
    @templates = QuoteTemplate.for_company(current_company)
  end

  def quote_params
    params.require(:quote).permit(
      :template_type,
      :project_size,
      :project_address,
      :project_city,
      :project_state,
      :project_zip_code,
      :notes,
      :terms,
      :payment_terms,
      :timeline_estimate,
      :valid_days,
      :client_id,
      client_attributes: [:name, :email, :phone, :address, :city, :state, :zip_code],
      line_items_attributes: [
        :id,
        :category,
        :description,
        :quality_tier,
        :is_allowance,
        :is_range,
        :range_low,
        :range_high,
        :internal_notes,
        :sort_order,
        :_destroy
      ]
    )
  end
end
