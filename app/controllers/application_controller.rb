# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  # Authentication
  before_action :authenticate_user!
  before_action :set_current_company

  # Pagination
  include Pagy::Backend

  # Error handling
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  protected

  def set_current_company
    return unless user_signed_in?

    @current_company = current_user.company
  end

  def current_company
    @current_company
  end
  helper_method :current_company

  def require_company!
    return if current_company.present?

    redirect_to edit_company_path, alert: "Please set up your company first."
  end

  def record_not_found
    respond_to do |format|
      format.html { redirect_to root_path, alert: "Record not found." }
      format.turbo_stream { head :not_found }
      format.json { render json: { error: "Record not found" }, status: :not_found }
    end
  end

  def after_sign_in_path_for(resource)
    if resource.company.blank?
      edit_company_path
    else
      dashboard_path
    end
  end

  def after_sign_out_path_for(_resource_or_scope)
    root_path
  end
end
