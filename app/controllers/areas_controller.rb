class AreasController < ApplicationController
  before_action :set_area, only: [:show]

  def show

    @properties_area = Property.where("\"properties\".\"area_id\" = ? AND photos_count > ?", @area.id, 0).with_attached_property_photos
    @search = @properties_area.ransack(params[:q])
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

    def set_area
      @area = Area.find_by(slug: params[:slug]) or not_found
    end

    def area_params
      params.require(:area).permit(:area, :slug)
    end
end
