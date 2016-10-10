class ProductsController < ApplicationController
  # GET /products
  # GET /products.json
  def index
    @type = params[:type].to_sym
    @products = Product.all(@type)

    unless Product.stage(@type)
      respond_to do |format|
        format.html { render :register }
        format.json { head :no_content }
      end
    end
  end

  # GET /products/1
  # GET /products/1.json
  def show
    @type = params[:type].to_sym
    @product = Product.find(@type, params[:name])
  end

  # GET /products/new
  def new
    @type = params[:type].to_sym
    @product = Product.build(type: @type)
  end

  # GET /products/1/edit
  def edit
    @type = params[:type].to_sym
    @product = Product.find(@type, params[:name])
  end

  # POST /products
  # POST /products.json
  def create
    @type = params[:type].to_sym
    @product = Product.build(product_params.merge(type: @type))

    respond_to do |format|
      if @product.save
        format.html { redirect_to product_url(@product.name, type: @type), notice: 'Product was successfully created.' }
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
    @product = Product.find(@type, params[:name])

    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to product_url(@product.name, type: @type), notice: 'Product was successfully updated.' }
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
    @product = Product.find(@type, params[:name])

    @product.destroy
    respond_to do |format|
      format.html { redirect_to products_url(type: @type), notice: 'Product was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # PATCH/PUT /products/1/cli/bundle_install
  CMDS = {
    bundle_install:    [{"HOME" => ""}, "bin/bundle install --path=vendor/bundle"],
    precompile_assets: [{"RAILS_ENV" => "production"}, "bin/rake assets:clobber && bin/rake assets:precompile && bin/rake tmp:clear"],
    restart_app:       ["mkdir -p tmp && touch tmp/restart.txt && echo 'Done!'"]
  }
  def cli
    cmd = CMDS[params[:cmd].to_sym]
    raise ActionController::RoutingError.new('Not Found') unless cmd
    @type = params[:type].to_sym
    @product = Product.find(@type, params[:name])

    response.headers['Content-Type'] = 'text/plain'
    Dir.chdir(@product.router.path) do
      Bundler.with_clean_env do
        Open3.popen2e(*cmd) do |i, o, t|
          o.each do |line|
            response.stream.write line
          end
        end
      end
    end
  ensure
    response.stream.close
  end

  def dispatch(name, *args)
    extend ActionController::Live if name.to_s == 'cli'
    super
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def product_params
      params.require(:product).permit! if params[:product]
    end
end
