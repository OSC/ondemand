# The controller for product pages (app development)
# /dashboard/admin/[dev,usr]/products/<token>.
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
    # Only allow user to clone existing apps in shared environment
    redirect_to new_from_git_remote_products_url if @type == :usr
  end

  # GET /products/new_from_git_remote
  def new_from_git_remote
    @type = params[:type].to_sym
    @product = Product.build(type: @type)
  end

  # GET /products/1/edit
  def edit
    @type = params[:type].to_sym
    @product = Product.find(@type, params[:name])
  end

  # POST /create_from_git_remote
  # POST /create_from_git_remote.json
  def create_from_git_remote
    @type = params[:type].to_sym
    @product = Product.build(product_params.merge(type: @type))

    respond_to do |format|
      if @product.create_from_git_remote(reset_git: params[:reset_git] == "1")
        format.html { redirect_to product_url(@product.name, type: @type), notice: 'Product was successfully created.' }
        format.json { render :show, status: :created, location: @product }
      else
        format.html { render :new_from_git_remote }
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

  # POST /create_key
  # POST /create_key.json
  def create_key
    @type = params[:type].to_sym

    target = Pathname.new("~/.ssh/id_rsa").expand_path

    if !target.file?
      o, s = Open3.capture2e("ssh-keygen", "-t", "rsa", "-b", "4096", "-N", "", "-f", "#{ENV['HOME']}/.ssh/id_rsa")
      success = s.success?
    else
      o = "SSH key already exists"
      success = false
    end

    respond_to do |format|
      if success
        format.html { redirect_to products_url(type: @type), notice: 'SSH key was successfully created.' }
        format.json { head :no_content }
      else
        format.html { redirect_to products_url(type: @type), alert: "SSH key failed to be created: #{o}"  }
        format.json { render json: o, status: :internal_server_error }
      end
    end
  end

  # PATCH/PUT /products/1/cli/bundle_install
  CMDS = {
    bundle_install:              [{"HOME" => ""}, "bundle install --path=vendor/bundle"],
    precompile_assets:           [{"RAILS_ENV" => "production"}, "bin/rake assets:clobber && bin/rake assets:precompile && bin/rake tmp:clear"],
    restart_app:                 ["mkdir -p tmp && touch tmp/restart.txt && echo 'Done!'"],
    rebuild_passenger_rails_app: [{"HOME" => "", "RAILS_ENV" => "production"}, "bundle install --path=vendor/bundle && bin/rake assets:clobber && bin/rake assets:precompile && bin/rake tmp:clear && mkdir -p tmp && touch tmp/restart.txt && echo 'Done!'"]
  }
  def cli
    cmd = CMDS[params[:cmd].to_sym]
    raise ActionController::RoutingError.new('Not Found') unless cmd
    @type = params[:type].to_sym
    @product = Product.find(@type, params[:name])

    response.headers['Content-Type'] = 'text/plain'
    Dir.chdir(@product.router.path) do
      Bundler.with_unbundled_env do
        ENV['BUNDLE_USER_CONFIG'] = '/dev/null'
        Open3.popen2e(*cmd) do |i, o, t|
          o.each do |line|
            response.stream.write line
          end
          if t.value.success?
            response.stream.write %Q(<code><p class="text-success"><i class="fa fa-check" aria-hidden="true"></i> Ran successfully!</p></code>)
          else
            response.stream.write %Q(<code><p class="text-danger"><i class="fa fa-times" aria-hidden="true"></i> Something bad happened (exit code = #{t.value.exitstatus})</p></code>)
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
