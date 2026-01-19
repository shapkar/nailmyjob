# frozen_string_literal: true

module Portal
  class BaseController < ActionController::Base
    # No authentication required for portal
    # Uses magic link tokens instead

    layout "portal"

    protect_from_forgery with: :exception

    helper_method :current_company

    private

    def current_company
      @current_company
    end
  end
end
