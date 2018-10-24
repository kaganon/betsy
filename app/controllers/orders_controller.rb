class OrdersController < ApplicationController
  include ApplicationHelper

  def index
  end

  def show
    @order = Order.find_by(id: params[:id])
    unless @order
      render :nosnacks, status: :bad_request
    end
  end

  def create
    # @order = Order.new
    #
    # if @order.save
    #
    #   session[:order_id] = @order.id
    #   order_item = OrderItem.new(order_items_params)
    #   order_item.order_id = @order.id
    #   order_item.product = Product.find_by(id: params[:product_id])
    #
    #   if order_item.save
    #     flash[:status] = :success
    #     flash[:result_text] = "Added item to cart"
    #
    #     redirect_to order_path(@order)
    #   else
    #     flash[:status] = :failure
    #     flash[:result_text] = "Could not add item to cart"
    #     flash[:messages] = order_item.errors.messages
    #     redirect_back fallback_location: root_path, status: :bad_request
    #   end
    #
    # else
    #   flash[:status] = :failure
    #   flash[:result_text] = "Problems with adding to cart"
    #   flash[:messages] = @order.errors.messages
    #   redirect_back fallback_location: root_path
    # end
  end

  def edit
    if @cart && @cart.id == params[:id].to_i
      @order = Order.find_by(id: params[:id])
    else
      flash.now[:status] = :failure
      flash.now[:result_text] = "Cannot edit nonexistent order"
      render :nosnacks, status: :bad_request
    end
  end

  def update
    @order = Order.find_by(id: params[:id])
    @order.update_attributes(order_params)

    if @order.status = 'pending'
      @order.update_attribute(:status, 'awaiting confirmation')
    end

    if @order.save
      @order.update_attribute(:order_placed, @order.updated_at)
      flash[:status] = :success
      flash[:result_text] = "Order Information Saved"
      redirect_to finalize_path(@order)
    else
      flash.now[:status] = :failure
      flash.now[:result_text] = "Could not complete order"
      flash.now[:messages] = @order.errors.messages
      render :edit, status: :bad_request
    end
  end

  def finalize
    unless @cart && @cart.id == params[:id].to_i
      flash.now[:status] = :failure
      flash.now[:result_text] = "Cannot finalize nonexistent order"
      render :nosnacks, status: :bad_request
    end

  end

  def confirmation
    if @cart
      @order = @cart
      @order.update_attribute(:status, 'paid')
      update_products(@order)
      session[:order_id] = nil
    else
      render :nosnacks, status: :bad_request
    end
  end

  def destroy
    if @cart && @cart.id == params[:id].to_i
      @cart.update_attribute(:status, 'cancelled')
      flash.now[:status] = :success
      flash.now[:result_text] = "Order Cancelled"
      session[:order_id] = nil
      render :nosnacks
    else
      flash.now[:status] = :failure
      flash.now[:result_text] = "Cannot empty nonexistent or unauthorized cart"
      render :nosnacks, status: :bad_request
    end
  end

  def nosnacks
    render :nosnacks, status: :bad_request
  end

  private

  def order_params
    params.require(:order).permit(
      :name,
      :email,
      :address,
      :cc_num,
      :cvv,
      :exp_month,
      :exp_year,
      :zip,
    )
  end

  # def order_items_params
  #   params.require(:order_item).permit(
  #     :quantity,
  #     :product_id
  #   )
  # end

end
