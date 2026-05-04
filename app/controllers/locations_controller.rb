class LocationsController < ApplicationController
  before_action :authenticate_user!, except: [:show, :index]
  load_and_authorize_resource
  skip_authorize_resource :only => [:show, :index]
  before_action :set_location, only: [:show]

  def new
    @location = Location.new
    # @location.parent = Location.find(params[:id]) unless params[:id].nil?
  end

  def create
    @location = Location.new(location_params)
    if @location.save!
      redirect_to locations_path(@location)
      flash[:info] = "Saved."
    else
      flash.now[:alert] = "Something went wrong..."
      render action: "new"
    end
  end

  def index
    @areas = Area.all
    @locations = Location.all
  end

  def show

    @properties_location = Property.where("\"properties\".\"location_id\" = ? AND photos_count > ?", @location.id, 0).with_attached_property_photos
    @search = @properties_location.ransack(params[:q])
    @properties = @search.result.paginate(page: params[:page], per_page: 16)
    @search.sorts = ['photos_count desc', 'updated_at desc', 'availability_date asc', 'name desc', 'bedrooms asc'] if @search.sorts.empty?

    @arrProperties = @properties.to_a

    respond_to do |format|
      format.html
      format.js {
        render :template => "search/search.js.erb"
      }
    end

  end

  private

    def set_location
      @location = Location.find_by(slug: params[:slug])
      if @location.blank?
        @location = Location.find(params[:slug])
      end
    end

    def location_params
      params.require(:location).permit(:name, :area_id, :slug)
    end

end
