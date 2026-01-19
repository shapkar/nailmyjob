# frozen_string_literal: true

class ClientsController < ApplicationController
  before_action :require_company!
  before_action :set_client, only: [:show, :edit, :update, :destroy, :regenerate_magic_link]

  def index
    @pagy, @clients = pagy(
      current_company.clients.includes(:quotes).recent,
      items: 20
    )
  end

  def show
    @quotes = @client.quotes.includes(job: :change_orders).recent.limit(10)
  end

  def new
    @client = current_company.clients.build
  end

  def create
    @client = current_company.clients.build(client_params)

    if @client.save
      respond_to do |format|
        format.html { redirect_to @client, notice: "Client created successfully." }
        format.turbo_stream { flash.now[:notice] = "Client created successfully." }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @client.update(client_params)
      respond_to do |format|
        format.html { redirect_to @client, notice: "Client updated successfully." }
        format.turbo_stream { flash.now[:notice] = "Client updated successfully." }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @client.destroy

    respond_to do |format|
      format.html { redirect_to clients_path, notice: "Client deleted successfully." }
      format.turbo_stream { flash.now[:notice] = "Client deleted successfully." }
    end
  end

  def search
    @clients = current_company.clients.search(params[:q]).limit(10)

    respond_to do |format|
      format.json { render json: @clients.map { |c| { id: c.id, name: c.name, email: c.email } } }
      format.turbo_stream
    end
  end

  def regenerate_magic_link
    @client.regenerate_magic_link!

    respond_to do |format|
      format.html { redirect_to @client, notice: "Magic link regenerated." }
      format.turbo_stream { flash.now[:notice] = "Magic link regenerated." }
    end
  end

  private

  def set_client
    @client = current_company.clients.find(params[:id])
  end

  def client_params
    params.require(:client).permit(
      :name,
      :email,
      :phone,
      :address,
      :city,
      :state,
      :zip_code,
      :notes
    )
  end
end
