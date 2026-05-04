class Api::V1::BaseController < ActionController::Base

  include Rails::Pagination
  require 'will_paginate/array'
  respond_to :json

  def pagination_dict(object)
    {
      current_page: object.current_page,
      next_page: object.next_page,
      previous_page: object.previous_page,
      total_pages: object.total_pages,
      total_entries: object.total_entries
    }
  end


end
