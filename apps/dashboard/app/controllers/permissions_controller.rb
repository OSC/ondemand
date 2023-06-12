# frozen_string_literal: true

# The controller for editing a shared app's permissions
# /dashboard/admin/usr/products/<token>/user/permissions.
class PermissionsController < ApplicationController
  # GET /permissions
  # GET /permissions.json
  def index
    @type = params[:type].to_sym
    @product = Product.find(@type, params[:product_name])
    @context = params[:context].to_sym
    @permissions = @product.permissions(@context)
  end

  # GET /permissions/new
  def new
    @type = params[:type].to_sym
    @product = Product.find(@type, params[:product_name])
    @context = params[:context].to_sym
    @permission = @product.build_permission(@context)
  end

  # POST /permissions
  # POST /permissions.json
  def create
    @type = params[:type].to_sym
    @product = Product.find(@type, params[:product_name])
    @context = params[:context].to_sym
    @permission = @product.build_permission(@context, permission_params)

    respond_to do |format|
      if @permission.save
        format.html do
          redirect_to product_url(@product.name, type: @type), notice: 'Permission was successfully created.'
        end
        format.json { render :show, status: :created, location: @permission }
      else
        format.html { render :new }
        format.json { render json: @permission.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /permissions/1
  # DELETE /permissions/1.json
  def destroy
    @type = params[:type].to_sym
    @product = Product.find(@type, params[:product_name])
    @context = params[:context].to_sym
    @permission = Permission.find(@context, @product, params[:name])

    @permission.destroy
    respond_to do |format|
      format.html do
        redirect_to product_url(@product.name, type: @type), notice: 'Permission was successfully destroyed.'
      end
      format.json { head :no_content }
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def permission_params
    params.require(:permission).permit! if params[:permission]
  end
end
