class SettingsController < ApplicationController
  def edit
    @setting = User.find(current_user.id).setting
    render 'users/registrations/notification_settings'
  end

  def update
    @setting = User.find(current_user.id).setting
    if @setting.update(setting_params)
      flash[:info] = "Settings updated!"

    else
      flash[:alert] = @setting.errors.full_messages.to_sentence
    end
    render 'users/registrations/notification_settings'
  end

  private

  def setting_params
    params.require(:setting).permit(:enable_email)
  end
end
