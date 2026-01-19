# frozen_string_literal: true

module Portal
  class ChangeOrdersController < Portal::BaseController
    before_action :set_change_order_by_token

    def show
      @change_order.mark_as_viewed!
    end

    def signature
      # This is the page where client reviews and signs
    end

    def sign
      unless valid_signature_params?
        render :signature, status: :unprocessable_entity
        return
      end

      @change_order.sign!(
        signature_data: params[:signature_data],
        signer_name: params[:signer_name],
        signer_email: params[:signer_email],
        signer_ip: request.remote_ip,
        signer_geolocation: params[:geolocation]
      )

      # Generate signed PDF
      ChangeOrderPdfGeneratorJob.perform_later(@change_order.id)

      # Send confirmation
      ChangeOrderMailer.signature_confirmation(@change_order).deliver_later

      # Redirect to the job portal with success message
      redirect_to portal_job_path(@job.client_view_token),
                  notice: "Thank you! Change order signed successfully."
    end

    private

    def set_change_order_by_token
      @change_order = ChangeOrder.includes(job: [:client, :company, :quote])
                                 .find_by!(client_view_token: params[:token])
      @job = @change_order.job
      @current_company = @job.company
    rescue ActiveRecord::RecordNotFound
      render "portal/errors/not_found", status: :not_found
    end

    def valid_signature_params?
      params[:signature_data].present? && params[:signer_name].present?
    end
  end
end
