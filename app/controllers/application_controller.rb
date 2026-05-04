class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :check_browser
  layout :determine_site
  before_action :determine_view_path


  def search
    #STEP 1
    if params[:search].present? && params[:search].strip != ""
      session[:loc_search] = params[:search]
    end

    #STEP 2
    if session[:loc_search] && session[:loc_search] != ""
      @property_location = Property.where(sold: [nil, false]).near(session[:loc_search], 5, order: 'distance')
    else
      if current_user.nil?
        @property_location = Property.where(sold: [nil, false]).where("(price >= ? AND contract_type = ?) OR contract_type = ? OR contract_type = ? OR contract_type = ?", 800, 1, 2, 3, 4).where("photos_count > ?", 0).with_attached_property_photos
      else
        @property_location = Property.where(sold: [nil, false])
      end
    end

    #STEP 3
    if params[:q].present?
      @search = @property_location.ransack(params[:q])
    else
      @search = @property_location.where(:contract_type => 1).ransack(params[:q])
    end
    @search.sorts = ['updated_at desc', 'availability_date asc', 'bedrooms asc'] if @search.sorts.empty?

    if action_name == "home"
      @properties = @search.result.paginate(page: params[:page], per_page: 12)
    else
      @properties = @search.result.paginate(page: params[:page], per_page: 16)
    end

    @q = params[:q].to_unsafe_h if params[:q].present?

    @arrProperties = @properties.to_a

    #STEP 4
    # if (params[:availability_date] && !params[:availability_date].empty?)
    #
    #   availability_date = Date.parse(params[:availability_date])
    #
    #   @properties.each do |property|
    #     not_available = property.availability_date.where(
    #       "((? <= availability_date - 30 OR availability_date + 30 >= ?)",
    #       availability_date, availability_date
    #     ).limit(1)
    #
    #     if not_available.length > 0
    #       @arrRooms.delete(property)
    #     end
    #   end
    # end

  end


  rescue_from CanCan::AccessDenied do | exception |
    flash[:error] = exception.message
    redirect_to main_app.root_path
  end

  rescue_from ActiveRecord::RecordNotUnique do
    # flash.now[:error] = @property.errors.full_messages.to_sentence
    flash.now[:error] = "It looks like that property is already listed. If it's a different one, please, toggle: 'The owner has more than one property like this' and add a different value."
    if request.xhr?
      render "shared/_message_js"
    else
      # flash.now[:error] = @property.errors.full_messages.to_sentence
      redirect_to root_path
      flash[:error] = "It looks like that property is already listed. If it's a different one, please, toggle: 'The owner has more than one property like this' and add a different value."
    end

  end

  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:nickname, :first_name, :last_name, :phone_number, :role_id, :avatar])
    devise_parameter_sanitizer.permit(:account_update, keys: [:nickname, :first_name, :last_name, :phone_number, :avatar])
  end

  def check_browser
    browser = Browser.new(request.headers['User-Agent'], accept_language: request.headers["Accept-Language"])
  end

  def determine_site
    select_layout = request.host
    if select_layout.include?('rocklandmalta.com') || select_layout.include?('jr-dev-07')
      "application_rockland"
    else
      "application_main"
    end
  end

  def determine_view_path
    prepend_view_path "#{Rails.root}/app/views/#{determine_site}"
    @request_url = request.host
  end

end
