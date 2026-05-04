class OwnersController < ApplicationController
  before_action :set_owner, except: [:index, :new, :create, :autocomplete_owner_phone_number, :autocomplete_owner_name, :autocomplete_owner_additional_info, :remind_to_call]
  before_action :authenticate_user!
  load_and_authorize_resource
  before_action :check_for_cancel, :only => [:create, :update]
  autocomplete :owner, :phone_number, :limit => 5, :extra_data => [:name]
  autocomplete :owner, :name, :limit => 10
  autocomplete :owner, :additional_info, :limit => 10

  def show
    @owner = Owner.find(params[:id])
    @owner_country = Country[@owner.phone_country_code]
    @owner_country_code = @owner_country.country_code
    @owner_phone = '+' + @owner_country_code + @owner.phone_number
    if browser.platform.android?
      if @owner.phone_country_code = "MT"
        redirect_to 'tel://' + @owner.phone_number
      else
        redirect_to 'tel://' + @owner_phone
      end
    else
      redirect_to 'tel://' + @owner_phone
    end
  end

  def edit
    session[:return_to] ||= request.referer
  end

  def update

    if @owner.update(owner_params)
      flash[:info] = "Saved."
    else
      flash[:alert] = @owner.errors.full_messages.to_sentence
    end
    redirect_to session.delete(:return_to)

  end

  def editor_update

    if @owner.update(owner_params)
      @property_owner = @owner
      flash[:info] = "Saved."
    else
      flash[:alert] = @owner.errors.full_messages.to_sentence
    end
    respond_to do |format|
      format.js {
        render "properties/editors/editor_update_owner.js.erb"
      }
      format.html
    end


  end

  def remind_to_call

    if !params[:reminder_date].blank?
      @property_ranked = Property.find(params[:property_id])
      @notifications = 1
      Resque.enqueue_in(params[:reminder_date].to_time - Time.now, ReminderToCallNotification, current_user.id, @property_ranked.id)
      PropertyMailer.remind_to_call(current_user.id, @property_ranked.id, @property_ranked.owner_id).deliver_in(params[:reminder_date].to_time - Time.now) if current_user.setting.enable_email
      flash.now[:info] = "Reminder added successfully. You'll receive a notification and an email on the date selected."
      render 'properties/editors/bottom_navbar/remind_to_call'
    else
      flash.now[:alert] = "Please, select a date."
      render 'shared/_message_js'
    end

  end


  private

  def set_owner
    @owner = Owner.find(params[:id])
  end

  def owner_params
    params.require(:owner).permit(:name, :phone_number, :phone_country_code, :additional_info)
  end

  def check_for_cancel
    if params[:commit] == "Cancel"
      redirect_to session.delete(:return_to)
    end
  end

end
