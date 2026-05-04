class Users::RegistrationsController < Devise::RegistrationsController

  before_action :set_user, only: [:show]
  before_action :authenticate_user!
  before_action :check_sign_in
  # before_action :check_permissions

    ####################
    #    Redirects     #
    ####################

  def my_profile

    if current_user.role_id == "editor"
      @my_updates = Property.where(sold: [nil, false]).where("updated_by = ?", current_user.id)
      @search = @my_updates.ransack(params[:q])
      @properties = @search.result.paginate(page: params[:page], per_page: 16)
      @search.sorts = ['updated_at desc'] if @search.sorts.empty?

      @arrProperties = @properties.to_a
      @q = params[:q].to_unsafe_h if params[:q].present?
    else
      @my_listings = Property.where(sold: [nil, false]).where("assigned_to = ?", current_user.id)
      @search = @my_listings.ransack(params[:q])
      @properties = @search.result.paginate(page: params[:page], per_page: 16)
      @search.sorts = ['updated_at desc'] if @search.sorts.empty?

      @arrProperties = @properties.to_a
      @q = params[:q].to_unsafe_h if params[:q].present?
    end


    respond_to do |format|
      format.html
      format.js {
        render :template => "search/search.js.erb"
      }
    end
  end

  def my_profile_loadmore
    if current_user.role_id == "editor"
      @my_updates = Property.where(sold: [nil, false]).where("updated_by = ?", current_user.id)
      @search = @my_updates.ransack(params[:q])
      @properties = @search.result.paginate(page: params[:page], per_page: 16)
      @search.sorts = ['updated_at desc'] if @search.sorts.empty?

      @arrProperties = @properties.to_a
      @q = params[:q].to_unsafe_h if params[:q].present?
    else
      @my_listings = Property.where(sold: [nil, false]).where("assigned_to = ?", current_user.id)
      @search = @my_listings.ransack(params[:q])
      @properties = @search.result.paginate(page: params[:page], per_page: 16)
      @search.sorts = ['updated_at desc'] if @search.sorts.empty?

      @arrProperties = @properties.to_a
      @q = params[:q].to_unsafe_h if params[:q].present?
    end


    respond_to do |format|
      format.html
      format.js {
        render :template => "users/registrations/my_profile_loadmore.js.erb"
      }
    end

  end

  def edit_profile
    @user = current_user
  end

  def change_password
    @user = current_user
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation, :role_id, :avatar)
  end

  def check_sign_in
    if current_user.nil?
      flash[:alert] = "Please, login before continuing."
      redirect_to root_path
    else
      if user_signed_in?
        true
      else
        flash[:alert] = "Please, login before continuing."
        redirect_to root_path
      end
    end
  end

  # def check_permissions
  #   authorize! :create, resource
  # end

end
