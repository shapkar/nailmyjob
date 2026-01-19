# frozen_string_literal: true

class DashboardController < ApplicationController
  before_action :require_company!, only: [:index]

  def index
    @recent_quotes = current_company.quotes
                                    .includes(:client)
                                    .recent
                                    .limit(5)

    @quotes_needing_attention = current_company.quotes
                                               .includes(:client)
                                               .needs_attention
                                               .limit(5)

    # Active jobs
    @active_jobs = current_company.jobs
                                  .includes(:client, :quote)
                                  .active_jobs
                                  .recent
                                  .limit(5)

    # Pending change orders (now from jobs)
    @pending_change_orders = ChangeOrder.joins(:job)
                                        .where(jobs: { company_id: current_company.id })
                                        .pending_signature
                                        .includes(job: :client)
                                        .limit(5)

    # Calculate profit defender metric (change orders captured)
    @change_orders_this_month = ChangeOrder.joins(:job)
                                           .where(jobs: { company_id: current_company.id })
                                           .signed
                                           .where("change_orders.signed_at >= ?", Time.current.beginning_of_month)
                                           .sum(:amount)

    # Stats for dashboard cards
    @stats = {
      total_quotes: current_company.quotes.count,
      quotes_this_month: current_company.quotes.where("created_at >= ?", Time.current.beginning_of_month).count,
      active_jobs: current_company.jobs.active_jobs.count,
      pending_signatures: @pending_change_orders.size
    }
  end
end
