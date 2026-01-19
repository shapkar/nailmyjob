# frozen_string_literal: true

class LineItemsController < ApplicationController
  before_action :require_company!
  before_action :set_quote
  before_action :set_line_item, only: [:update, :destroy]

  def create
    @line_item = @quote.line_items.build(line_item_params)

    if @line_item.save
      respond_to do |format|
        format.html { redirect_to edit_quote_path(@quote), notice: "Line item added." }
        format.turbo_stream { flash.now[:notice] = "Line item added." }
      end
    else
      respond_to do |format|
        format.html { redirect_to edit_quote_path(@quote), alert: @line_item.errors.full_messages.join(", ") }
        format.turbo_stream { render :create, status: :unprocessable_entity }
      end
    end
  end

  def update
    if @line_item.update(line_item_params)
      respond_to do |format|
        format.html { redirect_to edit_quote_path(@quote), notice: "Line item updated." }
        format.turbo_stream { flash.now[:notice] = "Line item updated." }
      end
    else
      respond_to do |format|
        format.html { redirect_to edit_quote_path(@quote), alert: @line_item.errors.full_messages.join(", ") }
        format.turbo_stream { render :update, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @line_item.destroy

    respond_to do |format|
      format.html { redirect_to edit_quote_path(@quote), notice: "Line item removed." }
      format.turbo_stream { flash.now[:notice] = "Line item removed." }
    end
  end

  def reorder
    params[:line_item_ids].each_with_index do |id, index|
      @quote.line_items.find(id).update(sort_order: index + 1)
    end

    head :ok
  end

  private

  def set_quote
    @quote = current_company.quotes.find(params[:quote_id])
  end

  def set_line_item
    @line_item = @quote.line_items.find(params[:id])
  end

  def line_item_params
    params.require(:line_item).permit(
      :category,
      :description,
      :quality_tier,
      :is_allowance,
      :is_range,
      :range_low,
      :range_high,
      :internal_notes,
      :sort_order
    )
  end
end
