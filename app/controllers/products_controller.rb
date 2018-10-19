class ProductsController < ApplicationController

  def homepage

  end

  def index
    @products = Product.all
  end

  def show
    @product = Work.find_by(id: params[:id])
    if @product.nil?
      head :not_found
    end
  end

  def new
    @product = Product.new
  end

  def create
    @product = Product.new(product_params)

    if @product.save
      flash[:success] = "Congratulations - you successfully entered a new product!"
      redirect_to products_path
    else
      flash.now[:error] = "The data you entered was not valid.  Please try again."
      render :new, status: :bad_request
    end
  end

  def edit
    @product = Product.find_by(id: params[:id])
  end

  def update
    @product = Product.find_by(id: params[:id])
    if @product.update(product_params)
      flash[:success] = "Successfully updated \"#{@product.name}\""
      redirect_to product_path(@proudct.id)
    else
      flash.now[:error] = "Invalid data"
      render :edit, status: :bad_request
    end
  end

  def destroy
    @product = Product.find_by(id: params[:id])
    if @product.destroy
      flash[:success] = "Successfully deleted \"#{@product.name}\" from the database."
      redirect_to products_path
    else
      redirect_back(fallback_location: products_path)
    end
  end

  private

  def product_params
    return params.require(:product).permit(
      :name,
      :price,
      :description,
      :img_file
    )
  end

end
