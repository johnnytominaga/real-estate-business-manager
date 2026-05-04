class LeadPropertiesController < ApplicationController

  private

  def set_property
    @property = Property.find(params[:id])
  end
  def lead_property_params
    params.require(:lead_property).permit(:property_id, :lead_id)
  end
end
