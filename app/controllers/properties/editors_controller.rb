class Properties::EditorsController < PropertiesController
  before_action :set_editor_property, only: [:editor_show]
  before_action :get_editor_property, only: [:editor_edit_field, :editor_update, :editor_add_photos, :update_editor_all, :stop_calling, :not_answering, :editor_done, :editor_new_property, :editor_all_add_3_months, :editor_all_add_6_months]
  before_action :authenticate_user!
  skip_before_action :verify_authenticity_token, if: :json_request?
  after_action :update_photos_count, only: [:editor_update]

  def editor_show

    @property_owner = Owner.find(@property_ranked.owner_id)
    @owner_properties = @property_ranked.properties_from_owner(@property_ranked.id)
    @notifications = 0

    respond_to do |format|
      format.html
      format.js
    end

  end

  def editor_new_property
    @property_owner = Owner.find(@property.owner_id)
    respond_to do |format|
      format.html
      format.js
    end
  end

  def editor_create_property

    @user = current_user

    if @user.listing_rights?
      @assigned_user = @user
    else
      @assigned_user = User.find(2)
    end

    new_params = property_params
    new_params = property_params.merge(created_by: current_user.id, assigned_to: @assigned_user.id)
    @property = Property.new(new_params)

    if params[:editor_save_and_add_photos]

      if @property.save
        @property_ranked = @property
        @property_owner = Owner.find(@property_ranked.owner_id)
        flash[:info] = "New property created successfully! Search for property ID: #{@property.id} to add photos."
        respond_to do |format|
          format.js {
            render "properties/editors/editor_create_property"
          }
          format.html
        end
      else
        flash.now[:alert] = @property.errors.full_messages.to_sentence
        render "shared/_message_js"
      end


    elsif params[:editor_save_new]

      if @property.save
        @property_ranked = @property
        @property_owner = Owner.find(@property_ranked.owner_id)
        flash[:info] = "Congratulations! New property created successfully!"
        respond_to do |format|
          format.js {
            render "properties/editors/editor_create_property"
          }
          format.html
        end

      else
        flash.now[:alert] = @property.errors.full_messages.to_sentence
        render "shared/_message_js"
      end

    end

  end

  def editor_add_photos
    @property_ranked = Property.where(sold: [nil, false]).where("id = ?, #{params[:propertyId]}")
    render partial: "properties/editors/editor_add_photos"
  end

  def update_editor_all
    new_params = property_params

    if params[:cancel]
      @property_ranked = @property
      @owner_properties = Property.where(sold: [nil, false]).where("owner_id = ?", @property.owner_id)
      render editors_editor_update_availability_date_properties_path

    else
      availability_date = property_params[:availability_date]
      @owner = @property.owner_id
      @properties = Property.where(owner_id: @owner)
      @owner_properties = @properties
      if @properties.update_all(availability_date: availability_date, updated_by: current_user.id, updated_at: DateTime.now)
        flash.now[:info] = "All properties have been updated."
        @property_ranked = Property.find(@property.id)
      else
        flash.now[:alert] = @properties.errors.full_messages.to_sentence
      end
      respond_to do |format|
        format.js {
          render editors_editor_update_availability_date_properties_path
        }
        format.html
      end

    end


  end

  def editor_edit_property
    @edit_property = Property.find(params[:id])
    @property = @edit_property
    @is_editor = true
    respond_to do |format|
      format.js {
        render "properties/editors/editor_edit_property", property: params[:id], original: params[:original]
      }
    end
  end

  def editor_edit_field

    @this_or_all = "#{params[:update_all]}"

    if !@this_or_all.blank?
      @property_ranked = Property.where(sold: [nil, false]).where("id = ?, #{params[:propertyId]}")
      render partial: "properties/editors/editor_form_all_availability_dates"
    else
      @property_ranked = Property.where(sold: [nil, false]).where("id = ?, #{params[:propertyId]}")
      render partial: "properties/editors/#{params[:contract_type]}/edit_field_#{params[:attribute]}"
    end

  end

  def editor_update
    if params[:cancel]
      new_params = property_params
      @property_ranked = @property
      render edit_property_path

    elsif params[:cancel_update_availability]
      @property_ranked = @property
      @owner_properties = Property.where(sold: [nil, false]).where("owner_id = ?", @property.owner_id)
      render editors_editor_update_availability_date_properties_path

    elsif params[:update_availability]
      new_params = property_params
      new_params = property_params.merge(updated_by: current_user.id)

      if @property.update(new_params)
        flash.now[:info] = "Saved."
        @property_ranked = @property
        @owner_properties = Property.where(sold: [nil, false]).where("owner_id = ?", @property.owner_id)
      else
        @property_ranked = @property
        flash.now[:alert] = @property.errors.full_messages.to_sentence
      end
      respond_to do |format|
        format.js {
          render editors_editor_update_availability_date_properties_path
        }
        format.html
      end

    elsif params[:cancel_photos]
      @property_ranked = @property
      @property_owner = Owner.find(@property.owner_id)
      render editors_editor_add_photos_properties_path

    elsif params[:update_photos]
      new_params = property_params
      new_params = property_params.merge(updated_by: current_user.id)

      if @property.update(new_params)
        @property_ranked = @property
        @property_owner = Owner.find(@property.owner_id)
        flash.now[:info] = "New photos added successfully!"
      else
        @property_ranked = @property
        flash.now[:alert] = @property.errors.full_messages.to_sentence
      end

      respond_to do |format|
        format.js {
          render editors_editor_add_photos_properties_path
        }
      end


    elsif params[:update_other_property]

      new_params = property_params

      if @property.assigned_to.blank? && @property.assigned_to == "0"
        new_params = property_params.merge(updated_by: current_user.id, assigned_to: User.find(2))
      else
        new_params = property_params.merge(updated_by: current_user.id)
      end

      if @property.update(new_params)
        @owner_properties = @property.properties_from_owner(params[:original])
        @property_ranked = Property.find(params[:original])
        flash.now[:info] = "Thanks a lot for the update!"

      else
        flash.now[:alert] = @property.errors.full_messages.to_sentence
      end
      respond_to do |format|
        format.js {
          render editors_editor_update_other_property_properties_path
        }
        format.html
      end

    elsif params[:editor_cancel_update]
      @property_ranked = @property
      @owner_properties = Property.where("owner_id = ?", @property.owner_id)
      render editors_editor_update_properties_path

    else params[:editor_update_property]

      new_params = property_params
      new_params = property_params.merge(updated_by: current_user.id)

      if @property.update(new_params)

        flash.now[:info] = "Saved."

        @property_ranked = @property

        # set property title
        @property_ranked.property_title

        # set property price
        if !@property_ranked.price.blank?
          @property_ranked.property_price
        else
          @price = "Not informed"
        end

        #set owner
        @owner = @property_ranked.property_owner
        @owner_phone = @property_ranked.property_owner_phone_number

        # #WHATSAPP SHARING
        @property_ranked.share_with_owner
      else
        @property_ranked = @property
        flash.now[:alert] = @property.errors.full_messages.to_sentence
      end
      respond_to do |format|
        format.js {
          render template: "properties/editors/editor_update"
        }
        format.html
      end

    end

  end

  def editor_edit_owner

    @property_owner = Owner.find(params[:id])

    respond_to do |format|
      format.js
      format.html
    end

  end

  def editor_all_add_3_months
    @owner = @property.owner_id
    @properties = Property.where(owner_id: @owner)
    @properties.each do |property|
      property.update_column(:updated_by, current_user.id)
      property.update_column(:availability_date, property.availability_date.to_time + 3.months)
    end
    flash.now[:info] = "Availability dates have been pushed in 3 months."
    @property_ranked = Property.find(@property.id)
    @owner_properties = Property.where(sold: [nil, false]).where("owner_id = ?", @property.owner_id).where.not(id: @property.id)
    respond_to do |format|
      format.js {
        render editors_editor_update_availability_date_properties_path
      }
      format.html
    end

  end

  def editor_all_add_6_months
    @owner = @property.owner_id
    @properties = Property.where(owner_id: @owner)
    @properties.each do |property|
      property.update_column(:updated_by, current_user.id)
      property.update_column(:availability_date, property.availability_date.to_time + 6.months)
    end
    flash.now[:info] = "Availability dates have been pushed in 6 months."
    @property_ranked = Property.find(@property.id)
    @owner_properties = Property.where(sold: [nil, false]).where("owner_id = ?", @property.owner_id).where.not(id: @property.id)
    respond_to do |format|
      format.js {
        render editors_editor_update_availability_date_properties_path
      }
      format.html
    end

  end

  def stop_calling

    @owner = @property.owner_id
    @properties = Property.where(owner_id: @owner)

    if @properties.update_all(stop_calling: true, updated_by: current_user.id, updated_at: DateTime.now, availability_date: Date.today() + 180.days)
      flash[:info] = "This owner's properties will stop being listed."
      render 'properties/editors/editor_redirect'
    else
      flash.now[:alert] = @properties.errors.full_messages.to_sentence
      render 'shared/_message_js'
    end

  end

  def not_answering

    # @property.assign_attributes({ not_answering: true, updated_by: current_user.id })
    # if @property.save(validate: false)
    if @property.update_column(:not_answering, true) && @property.update_column(:availability_date, Date.today() + 15.days)
      flash[:info] = "Ok, let's call again later."
      render 'properties/editors/editor_redirect'
    else
      flash.now[:alert] = @property.errors.full_messages.to_sentence
      render 'shared/_message_js'
    end


  end

  def editor_done

    @owner = @property.owner_id
    @properties = Property.where(owner_id: @owner)

    if @property.update(updated_by: current_user.id, updated_at: DateTime.now)
      @properties.update_all(updated_at: DateTime.now)
      render 'properties/editors/editor_redirect'
      flash[:info] = "Updated successfully."

    else
      flash.now[:alert] = @property.errors.full_messages.to_sentence
      render 'shared/_message_js'
    end


  end


  private

  def set_editor_property
    @properties = Property.where(sold: [nil, false])

    if params[:q].present?
      @search = @properties.ransack(params[:q])
      @property_ranked = @search.result.first
      if @property_ranked.blank?
        flash.now[:alert] = "Owner not found. Please, try another number."
        render 'shared/_message_js'
      end
    else

      @search = @properties.ransack(params[:q])
      ranked = @properties.sort_by do |r|
        if !r.updated_at.blank? && r.updated_at != "0"
          @updated = r.updated_at
        else
          @updated = r.created_at
        end

        if !r.availability_date.blank? && r.availability_date != "0"
          [
            rank_updated_at(@updated).to_i,
            rank_availability_date(r.availability_date).to_i
          ].sum / 2.0
        else
          rank_updated_at(@updated)
        end
      end

      @ranked = ranked.reverse

      if Time.now.sec.to_i <= ranked.count
        @index = Time.now.sec.to_i
      else
        @index = 0
      end

      @property_ranked = @ranked[@index]     # CHANGE TO "@ranked[@index]" to randomize property


    end

  end

  def get_editor_property
    @property = Property.find(params[:id])
  end

  def rank_updated_at(date)
    days_ago = (Time.now - date).to_i / 1.day

    # ORIGINAL RATING
    # return 8 if 14 <= days_ago && days_ago <= 30 #using these were making only recent properties get updated again
    # return 7 if 9 <= days_ago && days_ago <= 13 #using these were making only recent properties get updated again
    # return 6 if (31 <= days_ago && days_ago <= 60) || (165 <= days_ago && days_ago <= 195)
    # return 5 if (350 <= days_ago && days_ago <= 380)
    # return 4 if 61 <= days_ago && days_ago <= 90
    # return 3 if (91 <= days_ago && days_ago <= 164) || (196 <= days_ago && days_ago <= 349)
    # return 2 if days_ago >= 381
    # return 1 if days_ago <= 8

    # V2
    return 8 if days_ago >= 381
    return 7 if (350 <= days_ago && days_ago <= 380)
    return 6 if (91 <= days_ago && days_ago <= 164) || (196 <= days_ago && days_ago <= 349)
    return 5 if 61 <= days_ago && days_ago <= 90
    return 4 if (31 <= days_ago && days_ago <= 60) || (165 <= days_ago && days_ago <= 195)
    return 3 if 14 <= days_ago && days_ago <= 30
    return 2 if 9 <= days_ago && days_ago <= 13
    return 1 if days_ago <= 8


  end

  def rank_availability_date(date)
    days_ago = (Time.now - date).to_i / 1.day
    return 12 if -7 <= days_ago && days_ago <= 0
    return 11 if 1 <= days_ago && days_ago <= 7
    return 10 if -14 <= days_ago && days_ago <= -7
    return 9 if (-21 <= days_ago && days_ago <= -14) || (125 <= days_ago && days_ago <= 140) || (260 <= days_ago && days_ago <= 280)
    return 8 if 8 <= days_ago && days_ago <= 14
    return 7 if -28 <= days_ago && days_ago <= -22
    return 6 if 15 <= days_ago && days_ago <= 21
    return 5 if 22 <= days_ago && days_ago <= 28
    return 4 if (-56 <= days_ago && days_ago <= -29) || (29 <= days_ago && days_ago <= 56)
    return 3 if (-112 <= days_ago && days_ago <= -57) || (57 <= days_ago && days_ago <= 112)
    return 2 if (-168 <= days_ago && days_ago <= -113) || (111 <= days_ago && days_ago <= 124) || (141 <= days_ago && days_ago <= 259)
    return 1 if (281 >= days_ago) || (days_ago <= -169)
  end


end
