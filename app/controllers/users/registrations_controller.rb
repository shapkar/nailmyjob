# frozen_string_literal: true

module Users
  class RegistrationsController < Devise::RegistrationsController
    before_action :configure_permitted_parameters

    protected

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name])
    end

    def after_sign_up_path_for(resource)
      edit_company_path
    end

    def after_update_path_for(resource)
      dashboard_path
    end
  end
end
