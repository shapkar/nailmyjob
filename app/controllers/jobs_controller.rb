# frozen_string_literal: true

class JobsController < ApplicationController
  before_action :set_job, only: [:show, :edit, :update]
  before_action :authorize_job, only: [:show, :edit, :update]

  def index
    @jobs = current_company.jobs.includes(:client, :quote).recent

    # Filter by status
    if params[:status].present?
      @jobs = @jobs.where(status: params[:status])
    end

    @pagy, @jobs = pagy(@jobs, limit: 20)
  end

  def show
    @change_orders = @job.change_orders.includes(:line_item).recent
  end

  def edit
  end

  def update
    if @job.update(job_params)
      redirect_to @job, notice: "Job updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # Actions for changing job status
  def start
    @job = current_company.jobs.find(params[:id])
    authorize_job

    @job.update!(start_date: Date.current, status: :active)
    redirect_to @job, notice: "Job started!"
  end

  def complete
    @job = current_company.jobs.find(params[:id])
    authorize_job

    @job.update!(actual_completion_date: Date.current, status: :completed)
    redirect_to @job, notice: "Job marked as completed!"
  end

  def hold
    @job = current_company.jobs.find(params[:id])
    authorize_job

    @job.update!(status: :on_hold)
    redirect_to @job, notice: "Job placed on hold."
  end

  def resume
    @job = current_company.jobs.find(params[:id])
    authorize_job

    @job.update!(status: :active)
    redirect_to @job, notice: "Job resumed."
  end

  private

  def set_job
    @job = Job.find(params[:id])
  end

  def authorize_job
    redirect_to jobs_path, alert: "Not authorized" unless @job.company_id == current_company.id
  end

  def job_params
    params.require(:job).permit(
      :project_address,
      :project_city,
      :project_state,
      :project_zip_code,
      :start_date,
      :estimated_completion_date,
      :notes
    )
  end
end
