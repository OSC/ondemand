class ProductsController < ApplicationController
  # GET /products
  # GET /products.json
  def index
    @type = params[:type].to_sym
    @products = Product.all(@type)
  end

  # GET /products/1
  # GET /products/1.json
  def show
    @type = params[:type].to_sym
    @product = Product.find(@type, params[:id])
  end

  # GET /products/new
  def new
    @type = params[:type].to_sym
    @product = Product.new
  end

  # GET /products/1/edit
  def edit
    @type = params[:type].to_sym
    @product = Product.find(@type, params[:id])
  end

  # POST /products
  # POST /products.json
  def create
    @type = params[:type].to_sym
    @product = Product.new(product_params)

    respond_to do |format|
      if @product.save
        format.html { redirect_to @product, notice: 'Product was successfully created.' }
        format.json { render :show, status: :created, location: @product }
      else
        format.html { render :new }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /products/1
  # PATCH/PUT /products/1.json
  def update
    @type = params[:type].to_sym
    @product = Product.find(@type, params[:id])

    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to @product, notice: 'Product was successfully updated.' }
        format.json { render :show, status: :ok, location: @product }
      else
        format.html { render :edit }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1
  # DELETE /products/1.json
  def destroy
    @type = params[:type].to_sym
    @product = Product.find(@type, params[:id])

    @product.destroy
    respond_to do |format|
      format.html { redirect_to products_url, notice: 'Product was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def product_params
      params.require(:product).permit! if params[:product]
    end
end
