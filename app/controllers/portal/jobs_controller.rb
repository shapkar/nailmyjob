# frozen_string_literal: true

module Portal
  class JobsController < ApplicationController
    skip_before_action :authenticate_user!
    layout "portal"

    before_action :set_job

    def show
      # Load all change orders that clients can see (not drafts)
      @change_orders = @job.change_orders.includes(:line_item).where.not(status: :draft)
      @signed_change_orders = @change_orders.where(status: :signed)
      @pending_change_orders = @change_orders.where(status: [:sent, :viewed])
    end

    private

    def set_job
      @job = Job.includes(:quote, :client, :company).find_by!(client_view_token: params[:token])
      @company = @job.company
    rescue ActiveRecord::RecordNotFound
      render "portal/errors/not_found", status: :not_found
    end
  end
end
