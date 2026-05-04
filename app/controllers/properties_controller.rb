class PropertiesController < ApplicationController
  # before_action :set_property, except: [:index, :search, :loadmore, :new, :create, :delete_photo_attachment, :editor_create_property, :my_updates, :agent_search, :editor]
  before_action :set_property, only: [:edit, :show, :update, :owner_details, :download_all_photos, :download_all_photos_without_watermark, :show_leads]
  before_action :authenticate_user!, except: [:index, :show, :loadmore]
  skip_before_action :verify_authenticity_token, if: :json_request?
  # before_action :is_authorized, only: [:update]
  # before_action :sanitize_property_params
  after_action :update_photos_count, only: [:update, :delete_photo_attachment]


  def new
    @property = Property.new
  end

  def create

    @user = current_user

    if @user.listing_rights?
      @assigned_user = @user
    else
      @assigned_user = User.find(2)
    end

    new_params = property_params
    if !property_params[:assigned_to].blank?
      new_params = property_params.merge(created_by: current_user.id)
    else
      new_params = property_params.merge(created_by: current_user.id, assigned_to: @assigned_user.id)
    end

    @property = Property.new(new_params)

      if @property.save
        redirect_to property_path(@property)
        flash[:info] = "Congratulations! New property created successfully!"
      else
        flash.now[:alert] = @property.errors.full_messages.to_sentence
        new_params = @property
        render action: "new"
      end

  end

  def delete_photo_attachment
    @attachment = ActiveStorage::Attachment.find(params[:id])
    @photo = @attachment.signed_id
    @blob = ActiveStorage::Blob.find_signed(@photo)
    session[:id] = @attachment.record_id
    @property = Property.find(session[:id])
    @blob.purge
    @attachment.purge

    if @property.update(updated_by: current_user.id)
      flash.now[:info] = "Photo deleted successfully!"
    else
      flash.now[:alert] = @attachment.errors.full_messages.to_sentence
    end

    respond_to do |format|
      format.js {
        render "properties/show/property_carousel"
      }
      format.html

    end


  end

  def edit

    #Routes Property Updates through JS - Rails automatically redirects to JS file
  end

  def index
    search
    respond_to do |format|
      format.html
      format.js {
        render :template => "search/search.js.erb"
      }
    end
  end

  def loadmore
    search
    respond_to do |format|
      format.html
      format.js {
        render :template => "search/loadmore.js.erb"
      }
    end
  end

  def agent_search
    search
    respond_to do |format|
      format.html
      format.js {
        render :template => "pages/agent/agent.js.erb"
      }
    end

  end

  def show

    @areas = Area.all
    if current_user.blank?
      @lead = Lead.new
    else

      if !@property.price.blank?
        @leads = Lead.where("contract_type = ? AND check_in_date BETWEEN ? AND ? AND bedrooms >= ? AND user_id = ?", Property.contract_types[@property.contract_type], @property.availability_date - 30.days, @property.availability_date + 30.days, @property.bedrooms, current_user.id)
                      .joins(:lead_areas).where("\"lead_areas\".\"area_id\" = ?", @property.area_id).budget_range(@property.price, @property.contract_type)
                      .order("name ASC").paginate(:page => params[:page], :per_page => 5)
      else
        @leads = Lead.where("contract_type = ? AND check_in_date BETWEEN ? AND ? AND bedrooms >= ? AND user_id = ?", Property.contract_types[@property.contract_type], @property.availability_date - 30.days, @property.availability_date + 30.days, @property.bedrooms, current_user.id)
                      .joins(:lead_areas).where("\"lead_areas\".\"area_id\" = ?", @property.area_id).budget_range(0, @property.contract_type)
                      .order("name ASC").paginate(:page => params[:page], :per_page => 5)
      end
    end

    #PROPERTIES SUGGESTIONS
    @property_suggestions = if !@property.availability_date.blank? && @property.availability_date != "0"
      Property.where(sold: [nil, false]).where(
      "(location_id = ?) AND (availability_date BETWEEN ? AND ?) AND (id != ?)",
      @property.location, @property.availability_date - 60*60*24*30,
      @property.availability_date + 60*60*24*30,
      @property.id
    ).order('updated_at DESC').take(4)
    end

    @properties_from_owner = Property.where(sold: [nil, false]).where(
      "(owner_id = ?) AND (id != ?)",
      @property.owner_id, @property.id
    ).order('updated_at DESC').take(4)

    # if @request_url.include?('rocklandmalta.com') || @request_url.include?('jr-dev-07')
    #   @watermark_path = Rails.root.join('app', 'assets', 'images', 'watermark-rockland.png')
    # else
    #   @watermark_path = Rails.root.join('app', 'assets', 'images', 'watermark.png')
    # end

  end

  def update

    if params[:cancel]
      new_params = property_params
      render edit_property_path

    else

      new_params = property_params
      new_params = property_params.merge(updated_by: current_user.id)

      if @property.update(new_params)

        # set property title
        @property.property_title

        # set property price
        if !@property.price.blank?
          @property.property_price
        else
          @price = "Not informed"
        end

        #set owner
        @owner = @property.property_owner
        @owner_phone = @property.property_owner_phone_number

        #WHATSAPP SHARING
        @property.share_with_owner
        @property.share_with_owner_encoded
        @property.share_without_owner
        @property.share_without_owner_encoded

        flash.now[:info] = "Thanks a lot for the update!"
      else
        flash.now[:alert] = @property.errors.full_messages.to_sentence
        # render 'shared/_message_js'
      end
      respond_to do |format|
        format.js
        format.html
      end
    end
  end

  def owner_details

    @owner = Owner.find(@property.owner_id)

    respond_to do |format|
      format.js
      format.html
    end

  end

  def download_all_photos

    if @request_url.include?('rocklandmalta.com') || @request_url.include?('jr-dev-07')
      watermark_path = Rails.root.join('app', 'assets', 'images', 'watermark-rockland.png')
    else
      watermark_path = Rails.root.join('app', 'assets', 'images', 'watermark.png')
    end

    @photos = @property.property_photos
    if @photos.length > 0
      compressed_filestream = Zip::ZipOutputStream.write_buffer(::StringIO.new('')) do |zos|
        @photos.each do |photo|
          @photo = photo.variant(
            combine_options: {
              gravity: 'center',
              resize: '770X578',
              'auto-orient': true,
              draw: 'image Over 0,0 0,0 "' + (watermark_path).to_s + '"'
            }
          ).processed.service_url
          # file = @photo.download
          img = open(@photo).read
          zos.put_next_entry("photos-#{SecureRandom.hex(8)}.jpg")
          zos.print img
        end
      end
      compressed_filestream .rewind
      send_data(compressed_filestream.read, disposition: 'attachment', filename: "#{@property.id}_#{Date.today.strftime('%Y-%m-%d')}.zip")

    else
      session[:return_to] ||= request.referer
    end

  end

  def download_all_photos_without_watermark

    @photos = @property.property_photos
    if @photos.length > 0
      compressed_filestream = Zip::ZipOutputStream.write_buffer(::StringIO.new(''), Zip::TraditionalEncrypter.new('realestate')) do |zos|
        @photos.each do |photo|
          @photo = photo.variant(
            combine_options: {
              gravity: 'center',
              resize: '770X578',
              'auto-orient': true,
            }
          ).processed.service_url
          # file = @photo.download
          img = open(@photo).read
          zos.put_next_entry("photos-#{SecureRandom.hex(8)}.jpg")
          zos.print img
        end
      end
      compressed_filestream .rewind
      send_data(compressed_filestream.read, disposition: 'attachment', filename: "#{@property.id}_#{Date.today.strftime('%Y-%m-%d')}_without_watermark.zip")

    else
      session[:return_to] ||= request.referer
    end

  end

  def my_updates
    @my_updates = Property.where(sold: [nil, false]).where("updated_by = ?", current_user.id)
    @search = @my_updates.ransack(params[:q])
    @search.sorts = ['updated_at desc'] if @search.sorts.empty?
    @properties = @search.result.paginate(page: params[:page], per_page: 16)

    @arrProperties = @properties.to_a

    @q = params[:q].to_unsafe_h if params[:q].present?

    respond_to do |format|
      format.html
      format.js {
        render :template => "search/search.js.erb"
      }
    end
  end

  def my_bookmarks
    @my_bookmarks = Bookmark.where("user_id = ?", current_user.id)
    @bookmarked_properties = @my_bookmarks.map(&:property_id).uniq
    @properties = Property.where(sold: [nil, false]).where(id: @bookmarked_properties)
    @search = @properties.ransack(params[:q])
    @search.sorts = ['updated_at desc'] if @search.sorts.empty?
    @properties = @search.result.paginate(page: params[:page], per_page: 16)

    @arrProperties = @properties.to_a

    @q = params[:q].to_unsafe_h if params[:q].present?

    respond_to do |format|
      format.html
      format.js {
        render :template => "search/search.js.erb"
      }
    end

  end

  def show_leads
    @leads = Lead.where("contract_type = ? AND check_in_date BETWEEN ? AND ? AND bedrooms >= ? AND user_id = ?", Property.contract_types[@property.contract_type], @property.availability_date - 30.days, @property.availability_date + 30.days, @property.bedrooms, current_user.id)
                  .joins(:lead_areas).where("\"lead_areas\".\"area_id\" = ?", @property.area_id).budget_range(@property.price, @property.contract_type)
                  .order("name ASC").paginate(:page => params[:page], :per_page => 5)

    render 'properties/show/leads'
  end

  def create_lead_property

    @lead_property = LeadProperty.create(property_id: params[:property_id], lead_id: params[:lead_id], status: params[:status])
    @lead = Lead.find(@lead_property.lead_id)
    if @lead_property.save(validate: false)
      flash.now[:info] = "Property added! Go to the lead's page for more details."
    else
      flash.now[:alert] = @lead_property.errors.full_messages.to_sentence
    end

    respond_to do |format|
      format.js {
        render "properties/show/create_lead_property", locals: {lead_id: params[:lead_id], property_id: params[:property_id]}
      }
      format.html
    end

  end

  def delete_lead_property
    @lead_properties = LeadProperty.where("lead_id = ? AND property_id = ?", params[:lead_id], params[:property_id])
    if @lead_properties.each(&:destroy)
      @lead_property = ""
      flash.now[:info] = "Property removed from suggestions list."
    else
      flash.now[:alert] = @lead_properties.errors.full_messages.to_sentence
    end
    respond_to do |format|
      format.js {
        render "properties/show/create_lead_property", locals: {lead_id: params[:lead_id], property_id: params[:property_id]}
      }
      format.html
    end


  end


  # def preload
  #   today = Date.today
  #   reservations = @property.reservations.where("(start_date >= ? OR end_date >= ?) AND status = ?", today, today, 1)
  #   unavailable_dates = @property.calendars.where("status = ? AND day > ?", 1, today)
  #   special_dates = @property.calendars.where("status = ? AND day > ? AND price <> ?", 0, today, @property.price)
  #
  #   render json: {
  #     reservations: reservations,
  #     unavailable_dates: unavailable_dates,
  #     special_dates: special_dates
  #   }
  # end
  #
  # def preview
  #   start_date = Date.parse(params[:start_date])
  #   end_date = Date.parse(params[:end_date])
  #
  #   output = {
  #     conflict: is_conflict(start_date, end_date, @property)
  #   }
  #
  #   render json: output
  # end

  private

    # def is_conflict(start_date, end_date, property)
    #   check = property.reservations.where("(? < start_date AND end_date < ?) AND status = ?", start_date, end_date, 1)
    #   check_2 = property.calendars.where("day BETWEEN ? AND ? AND status = ?", start_date, end_date, 1).limit(1)
    #
    #   check.size > 0 || check_2.size > 0 ? true : false
    # end

    def set_property
      @property = Property.find(params[:id])

    end

    # def is_authorized
    #   redirect_to root_path, alert: "You don't have permission" unless current_user.id == @property.user_id
    # end


    def property_params
      params.require(:property).permit(:area_id, :owner_phone_number, :owner_name, :owner_phone_country_code, :owner_additional_info, :location_id, :bedrooms, :bathrooms, :kitchens, :property_type,
        :price, :premium, :address, :description, :style, :lift, :ac, :roof,
        :balconies, :yard, :seafront, :seaview, :swimming_pool, :jacuzzi, :unfurnished, :pet_friendly, :permit_class,
        :sqm, :office_rooms, :floor, :deposit, :electrics, :obs, :availability_date, :pics, :listed_by,
        :contract_type, :bookable, :active, :payment_format, :condition, :updated_by, :flat_no, :not_answering, :stop_calling, :old_id, :sold, :assigned_to, property_photos: [])
    end

    # def sanitize_property_params
    #   params[:type] = params[:type].to_i
    # end

    def find_signed(id)
      find ActiveStorage.verifier.verify(id, purpose: :blob_id)
    end

    def json_request?
      request.format.json?
    end

    def update_photos_count
      @photos_count = ActiveStorage::Attachment.where("record_type = ? AND record_id = ?", "Property", @property.id).count
      @property.update(photos_count: @photos_count)

    end

end
