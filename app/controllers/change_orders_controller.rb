# frozen_string_literal: true

class ChangeOrdersController < ApplicationController
  before_action :require_company!
  before_action :set_job
  before_action :set_change_order, only: [:show, :edit, :update, :destroy, :send_to_client, :preview_pdf, :download_pdf, :signature, :submit_signature]

  def index
    @change_orders = @job.change_orders.includes(:line_item).recent
  end

  def show
  end

  def new
    @change_order = @job.change_orders.build(
      legal_boilerplate: current_company.legal_boilerplate,
      category: params[:category] || :other,
      line_item_id: params[:line_item_id]
    )

    # Pre-fill from line item overage if provided
    if params[:line_item_id].present?
      line_item = @job.quote.line_items.find(params[:line_item_id])
      if line_item.overbudget?
        @change_order.description = "Upgrade to #{line_item.category.humanize}: #{line_item.final_selection}"
        @change_order.amount = line_item.overage_amount
        @change_order.category = line_item.category
      end
    end
  end

  def create
    @change_order = @job.change_orders.build(change_order_params)

    if @change_order.save
      redirect_to job_change_order_path(@job, @change_order), notice: "Change order created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @change_order.update(change_order_params)
      redirect_to job_change_order_path(@job, @change_order), notice: "Change order updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @change_order.destroy
    redirect_to @job, notice: "Change order deleted successfully."
  end

  def send_to_client
    if @job.client.blank?
      redirect_to job_change_order_path(@job, @change_order), alert: "No client associated with this job."
      return
    end

    # Generate PDF
    ChangeOrderPdfGeneratorJob.perform_later(@change_order.id)

    # Send email
    ChangeOrderMailer.send_to_client(@change_order).deliver_later
    @change_order.mark_as_sent!

    redirect_to job_change_order_path(@job, @change_order), notice: "Change order sent to #{@job.client.name}."
  end

  def signature
    # This view shows the signature pad for on-device signing
  end

  def submit_signature
    @change_order.sign!(
      signature_data: params[:signature_data],
      signer_name: params[:signer_name],
      signer_email: params[:signer_email],
      signer_ip: request.remote_ip,
      signer_geolocation: params[:geolocation]
    )

    # Generate signed PDF
    ChangeOrderPdfGeneratorJob.perform_later(@change_order.id)

    # Send confirmation email
    ChangeOrderMailer.signature_confirmation(@change_order).deliver_later

    redirect_to @job, notice: "Change order signed! Amount: #{@change_order.formatted_amount}"
  end

  def preview_pdf
    pdf = ChangeOrderPdfGenerator.new(@change_order).generate
    send_data pdf, filename: "CO-#{@change_order.co_number}-#{@job.job_number}.pdf", type: "application/pdf", disposition: "inline"
  end

  def download_pdf
    pdf = ChangeOrderPdfGenerator.new(@change_order).generate
    send_data pdf, filename: "CO-#{@change_order.co_number}-#{@job.job_number}.pdf", type: "application/pdf", disposition: "attachment"
  end

  private

  def set_job
    @job = current_company.jobs.find(params[:job_id])
  end

  def set_change_order
    @change_order = @job.change_orders.find(params[:id])
  end

  def change_order_params
    params.require(:change_order).permit(
      :description,
      :amount,
      :category,
      :delays_schedule,
      :delay_days,
      :is_time_and_materials,
      :hourly_rate,
      :legal_boilerplate,
      :line_item_id
    )
  end
end
