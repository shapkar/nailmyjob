# frozen_string_literal: true

module Portal
  class QuotesController < Portal::BaseController
    before_action :set_quote_by_token

    def show
      @quote.mark_as_viewed!
      @line_items = @quote.line_items

      # Change orders are now on jobs, not quotes
      # If quote has been converted to a job, get change orders from there
      if @quote.job.present?
        @signed_change_orders = @quote.job.change_orders.signed
        @pending_change_orders = @quote.job.change_orders.pending_signature
      else
        @signed_change_orders = []
        @pending_change_orders = []
      end
    end

    def sign
      unless valid_signature_params?
        render :show, status: :unprocessable_entity
        return
      end

      @quote.sign!(
        signature_data: params[:signature_data],
        signer_ip: request.remote_ip,
        signer_geolocation: params[:geolocation]
      )

      # Generate signed PDF
      QuotePdfGeneratorJob.perform_later(@quote.id)

      # Send confirmation
      QuoteMailer.signature_confirmation(@quote).deliver_later

      # After signing, redirect to the job portal if a job was created
      if @quote.job.present?
        redirect_to portal_job_path(@quote.job.client_view_token),
                    notice: "Thank you! Your signature has been recorded. Your project is now active."
      else
        redirect_to portal_quote_path(@quote.client_view_token),
                    notice: "Thank you! Your signature has been recorded."
      end
    end

    private

    def set_quote_by_token
      @quote = Quote.includes(:company, :client, :line_items, :job)
                    .find_by!(client_view_token: params[:token])
      @current_company = @quote.company
    rescue ActiveRecord::RecordNotFound
      render "portal/errors/not_found", status: :not_found
    end

    def valid_signature_params?
      params[:signature_data].present?
    end
  end
end
