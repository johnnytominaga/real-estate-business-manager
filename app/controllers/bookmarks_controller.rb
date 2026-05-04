class BookmarksController < ApplicationController
  before_action :authenticate_user!

  def create

    @bookmark = Bookmark.where("property_id = ? AND user_id = ?", params[:property_id], params[:user_id]).first

    if @bookmark
      @bookmark.destroy
    else
      Bookmark.create(bookmark_params)
    end

    respond_to do |format|
      format.js { render "users/create_bookmark", :locals => {:property_id => params[:property_id]} }
    end

  end

  def index

  end

  def destroy

  end

  private

  def bookmark_params
    params.permit(:user_id, :property_id)
  end


end
