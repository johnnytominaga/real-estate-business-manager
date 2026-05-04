class NotificationsController < ApplicationController
  require 'will_paginate/array'

  before_action :authenticate_user!

  def index
    current_user.unread = 0
    current_user.save
    @notifications = current_user.notifications.reverse.paginate(page: params[:page], per_page: 10)
  end

end
