class Properties::AgentsController < PropertiesController

  before_action :authenticate_user!

  def agent_index

    search_available_now
    search
    respond_to do |format|
      format.html
      format.js {
        render :template => "properties/agents/agent_index.js.erb"
      }
    end

  end

  def agent_loadmore
    search
    respond_to do |format|
      format.html
      format.js {
        render :template => "properties/agents/agent_loadmore.js.erb"
      }
    end
  end

  def agent_search
  end


  private

  def search_available_now

    @available_now = Property.where(sold: [nil, false]).where("availability_date >= ? AND availability_date <= ? AND photos_count > ?", 15.days.ago, 10.days.from_now, 0).ransack(params[:q])
    @available_properties = @available_now.result.paginate(page: params[:page], per_page: 9)

    @available_now.sorts = ['availability_date desc', 'updated_at desc', 'created_at desc'] if @available_now.sorts.empty?


    @arrAvailableProperties = @available_properties.to_a

  end

end
