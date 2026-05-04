class UsersController < ApplicationController
  require 'will_paginate/array'

  before_action :set_user, only: [:show, :users_loadmore]
  before_action :authenticate_user!
  load_and_authorize_resource

  def edit

  end

  def index
    @users = User.where.not('role_id = ? OR nickname = ?', 4, 'johnny').order('first_name').paginate(page: params[:page], per_page: 10)
  end

  def show
    @my_listings = Property.where(sold: [nil, false]).where("assigned_to = ?", @user.id)
    @search = @my_listings.ransack(params[:q])
    @properties = @search.result.paginate(page: params[:page], per_page: 16)
    @search.sorts = ['updated_at desc'] if @search.sorts.empty?

    @arrProperties = @properties.to_a
    @q = params[:q].to_unsafe_h if params[:q].present?

    respond_to do |format|
      format.html
      format.js {
        render :template => "search/search.js.erb"
      }
    end

  end

  def users_loadmore
    @my_listings = Property.where(sold: [nil, false]).where("assigned_to = ?", @user.id)
    @search = @my_listings.ransack(params[:q])
    @properties = @search.result.paginate(page: params[:page], per_page: 16)
    @search.sorts = ['updated_at desc'] if @search.sorts.empty?

    @arrProperties = @properties.to_a
    @q = params[:q].to_unsafe_h if params[:q].present?

    respond_to do |format|
      format.html
      format.js {
        render :template => "users/users_loadmore.js.erb"
      }
    end
  end

  private

  def set_user
    @user = User.find_by(nickname: params[:nickname])
    if @user.blank?
      @user = User.find(params[:nickname])
    end
  end

  def user_params
    params.require(:user).permit(:nickname, :first_name, :last_name, :email, :password, :password_confirmation, :role_id, :avatar)
  end


end
