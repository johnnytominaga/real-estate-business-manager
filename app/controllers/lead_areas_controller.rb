class LeadAreasController < ApplicationController

  private
#
  def set_lead
    @lead = Lead.find(params[:lead_id])
  end
  def lead_area_params
    params.require(:lead_area).permit(:area_id, :lead_id)
  end
end
