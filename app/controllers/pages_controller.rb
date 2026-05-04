class PagesController < ApplicationController

  before_action :authenticate_user!, except: [:home, :privacy_policy, :terms_conditions]


  def home

    if @lead.blank?
      @lead = Lead.new
    end
    @areas = Area.all

    search

    respond_to do |format|
      format.html
      format.js {
        render :template => "search/search.js.erb"
      }
    end

  end


  private


end
