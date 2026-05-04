class LeadsController < ApplicationController
  before_action :set_lead, except: [:index, :new, :create, :new_from_property, :create_from_property, :loadmore, :loadmore_my_leads, :new_from_agent, :create_from_agent, :edit_field, :edit_lead_phase, :update_lead_phase, :delete_lead_phase, :update_lead_property, :my_leads]
  before_action :authenticate_user!, only: [:edit, :update, :delete, :show, :index, :new_from_agent, :create_from_agent]
  before_action :is_authorized, only: [:edit, :update, :show]
  before_action :set_agent, only: [:show, :show_step1, :show_step2, :show_step3, :show_step4, :show_step5, :update_field]
  before_action :set_locations, only: [:show, :show_step1, :show_step2, :update_field]
  load_and_authorize_resource only: [:index]

  def new
    @lead = Lead.new
    @areas = Area.all
    @phase = Phase.find(1) #Information collection
  end

  def create
    @lead = Lead.where("phone = ?", lead_params[:phone]).first_or_initialize
    if @lead.new_record?

      new_params = lead_params
      if lead_params[:lead_phases_attributes].blank?
        new_params = lead_params.merge(
          lead_phases_attributes: [phase_id: 1, comment: "New lead"]
        ).reject{|_, v| v.blank?}
      else
        new_params = lead_params.reject{|_, v| v.blank?}
      end

      @lead = Lead.new(new_params)
      if @lead.save(new_params)
        flash.now[:info] = "Thanks for contacting us! We'll get back to you shortly."
        if !lead_params[:lead_properties_attributes].blank?
          @lead_property = @lead.lead_properties.last
        end
        Resque.enqueue(NewLeadNotification, @lead.id)

        if !@lead_property.blank?
          LeadMailer.new_lead_from_property(@lead.id, @lead_property.id).deliver
        else
          LeadMailer.new_lead(@lead.id).deliver
        end

        respond_to do |format|
          format.js {
            render 'leads/create'
          }
        end
      else
        flash.now[:alert] = @lead.errors.full_messages.to_sentence
        render "shared/_message_js"
      end
    else

      @lead_property = LeadProperty.where("lead_id = ? AND property_id = ?", @lead.id, lead_params.dig("lead_properties_attributes", "0", "property_id"))
      if @lead_property.exists?
        flash.now[:info] = "Thanks for your request. It looks like you've already contacted us about this property. We'll get to you shortly."
        render "shared/_message_js"
      else
        new_params = lead_params
        if lead_params[:lead_phases_attributes].blank?
          new_params = lead_params.merge(
            lead_phases_attributes: [phase_id: 1, comment: "Client contacted us again"]
          ).reject{|_, v| v.blank?}
        else
          new_params = lead_params.reject{|_, v| v.blank?}
        end
        if @lead.update_attributes(new_params)
          flash.now[:info] = "Thanks for contacting us! We'll get back to you shortly."
          if !lead_params[:lead_properties_attributes].blank?
            @lead_property = @lead.lead_properties.last
          end
          Resque.enqueue(ExistingLeadNotification, @lead.id)

          if !@lead_property.blank?
            LeadMailer.existing_lead(@lead.id, @lead_property.id).deliver
          end


          respond_to do |format|
            format.js {
              render 'leads/create'
            }
          end
        else
          flash.now[:alert] = @lead.errors.full_messages.to_sentence
          render "shared/_message_js"
        end
      end
    end
  end

  def edit
  end

  def index
    authorize! :lead, :index
    @agents = User.where("is_active = ?", true).where.not("id BETWEEN ? AND ? OR role_id = ?", 1, 2, 2 ) #filter out admin, system user, and editors
    params[:check_in_date] ||= Date.current.to_s
    @active_leads = Lead.where(dropped: [false, nil])

    if params[:q].present?
      params[:check_in_date] = params[:q][:check_in_date]
      params[:user_id] = params[:q][:user_id]
      params[:contract_type] = params[:q][:contract_type]
    end

    @search = @active_leads.ransack(params[:q])

    if params[:check_in_date].nil?
      params[:check_in_date] ||= Date.current.to_s
    end

    check_in_date = Date.parse(params[:check_in_date])
    first_of_month = (check_in_date).beginning_of_month
    end_of_month = (check_in_date).end_of_month

    if params[:user_id].present?
      @user_leads = @active_leads.where('(check_in_date BETWEEN ? AND ?) AND user_id = ?', first_of_month, end_of_month, params[:user_id])
    else
      @user_leads = @active_leads.where('check_in_date BETWEEN ? AND ?', first_of_month, end_of_month)
    end

    if params[:contract_type].present?
      @leads = @user_leads.where('contract_type = ?', params[:contract_type])
    else
      @leads = @user_leads
    end

    @search_table = @leads.ransack(params[:q])
    @search_table.sorts = ['check_in_date asc'] if @search_table.sorts.empty?
    @leads_list = @search_table.result.paginate(page: params[:page], per_page: 10)
    @arrLeads = @leads_list.to_a
    @q = params[:q].to_unsafe_h if params[:q].present?


  end

  def show

    if params[:step].present? && params[:step] = 1
      show_step1
    end

    if params[:step].present? && params[:step] = 2
      show_step2
    end

    if params[:step].present? && params[:step] = 3
      show_step3
    end

    if params[:step].present? && params[:step] = 4
      show_step4
    end

    if params[:step].present? && params[:step] = 5
      show_step5
    end


    if @lead.information_collected == true && @lead.property_found == true && @lead.negotiation_completed == true && @lead.deposit_paid == true
      # STEP 5
      @active = 5 #Highlight steps (lead_steps)
      show_step5

    elsif @lead.information_collected == true && @lead.property_found == true && @lead.negotiation_completed == true
      # STEP 4
      @active = 4
      show_step4

    elsif @lead.information_collected == true && @lead.property_found == true
      # STEP 3
      @active = 3
      show_step3

    elsif @lead.information_collected == true
      # STEP 2
      @active = 2
      show_step2

    else
      # STEP 1
      @active = 1
      show_step1

    end

  end

  def show_step1
    @phase_updates_p1 = LeadPhase.where("lead_id = ? AND phase_id = ?", @lead.id, 1).order("created_at DESC").paginate(:page => params[:page], :per_page => 5)
    @phase = Phase.find(1)
    if action_name != 'show'
      render 'leads/show/step1'
    end

  end

  def show_step2

    if params[:q].present?
      @all_properties = Property.where(sold: [nil, false]).where.not(price: ["0", nil])
    else
      @all_properties = Property.where(sold: [nil, false]).where.not(price: ["0", nil])
      if @locations.length > 0
        params[:q] = {:q => {}}.with_indifferent_access.merge(
          "contract_type_eq"=>"#{@lead.read_attribute_before_type_cast(:contract_type)}",
          "availability_date_gteq"=>"#{@lead.check_in_date - 15.days}",
          "availability_date_lteq"=>"#{@lead.check_in_date + 15.days}",
          "price_gteq"=>"#{@lead.min_budget}",
          "price_lteq"=>"#{@lead.max_budget}",
          "property_type_eq"=>"#{@lead.property_type}",
          "bedrooms_gteq"=>"#{@lead.bedrooms}"
        )
          .merge("location_name_cont_any" => @locations.map { |l| l.name})
      else
        params[:q] = {:q => {}}.with_indifferent_access.merge(
          "contract_type_eq"=>"#{@lead.read_attribute_before_type_cast(:contract_type)}",
          "availability_date_gteq"=>"#{@lead.check_in_date - 15.days}",
          "availability_date_lteq"=>"#{@lead.check_in_date + 15.days}",
          "price_gteq"=>"#{@lead.min_budget}",
          "price_lteq"=>"#{@lead.max_budget}",
          "property_type_eq"=>"#{@lead.property_type}",
          "bedrooms_gteq"=>"#{@lead.bedrooms}"
        ).merge("area_area_cont_any" => @areas.map { |a| a.area})

      end

    end
    @search = @all_properties.ransack(params[:q])
    @search.sorts = ['updated_at desc', 'availability_date asc', 'bedrooms asc'] if @search.sorts.empty?
    @properties = @search.result.paginate(page: params[:page], per_page: 16)
    @arrProperties = @properties.to_a
    @q = params[:q].to_unsafe_h if params[:q].present?

    # List lead_properties
    @lead_properties = @lead.lead_properties.map(&:property_id).uniq #Array of unique property_ids in lead_properties list
    @selected_properties = Property.where(id: @lead_properties).order("price ASC")
    @phase = Phase.find(2)

    if action_name != 'show'
      render 'leads/show/step2'
    end

    # if params[:step] = 2
    #   render 'leads/show/step2'
    # end

  end

  def show_step3
    @phase_updates_p3 = LeadPhase.where("lead_id = ? AND phase_id = ?", @lead.id, 3).order("created_at DESC").paginate(:page => params[:page], :per_page => 5)
    @properties = Property.joins(:leads).where("\"lead_properties\".\"lead_id\" = ? AND liked_by_lead = ? AND status != ?", @lead.id, true, 1).order("status DESC")

    @phase = Phase.find(3)


    if action_name != 'show'
      render 'leads/show/step3'
    end

  end

  def show_step4
    @phase_updates_p4 = LeadPhase.where("lead_id = ? AND phase_id = ?", @lead.id, 4).order("created_at DESC").paginate(:page => params[:page], :per_page => 5)
    @properties = Property.joins(:leads).where("\"leads\".\"id\" = ? AND status >= ?", @lead.id, 8).order("updated_at DESC")

    @phase = Phase.find(4)
    if action_name != 'show'
      render 'leads/show/step4'
    end
  end

  def show_step5
    @phase_updates_p5 = LeadPhase.where("lead_id = ? AND phase_id = ?", @lead.id, 5).order("created_at DESC").paginate(:page => params[:page], :per_page => 5)
    @properties = Property.joins(:leads).where("\"leads\".\"id\" = ? AND status >= ?", @lead.id, 9).order("updated_at DESC")

    @phase = Phase.find(5)
    if action_name != 'show'
      render 'leads/show/step5'
    end
  end


  def phase_completed
    if lead_params[:information_collected]
      if @lead.update(lead_params)
        @lead_areas = @lead.lead_areas.map(&:area_id).uniq
        @areas = Area.where(id: @lead_areas)
        @lead_locations = @lead.lead_locations.map(&:location_id).uniq
        @locations = Location.where(id: @lead_locations)

        @phase_updates_p1 = LeadPhase.where("lead_id = ? AND phase_id = ?", @lead.id, 1).order("created_at DESC").paginate(:page => params[:page], :per_page => 5)
        @phase = Phase.find(1)
        flash.now[:info] = "Saved."
        respond_to do |format|
          format.js {
            render 'leads/show/step1/done'
          }
          format.html
        end
      else
        flash.now[:alert] = @lead.errors.full_messages.to_sentence
      end

    elsif lead_params[:property_found]
      if @lead.update(lead_params)
        @lead_areas = @lead.lead_areas.map(&:area_id).uniq
        @areas = Area.where(id: @lead_areas)
        @lead_locations = @lead.lead_locations.map(&:location_id).uniq
        @locations = Location.where(id: @lead_locations)

        @all_properties = Property.where(sold: [nil, false])

        if params[:q].present?
          @search = @all_properties.ransack(params[:q])
        else
          if @locations.length > 0
            @search = @all_properties.where(location_id: [@locations.map{|l| l.id}], contract_type: @lead.contract_type).ransack(params[:q])
          else
            @search = @all_properties.where(area_id: [@areas.map{|a| a.id}], contract_type: @lead.contract_type).ransack(params[:q])
          end
        end
        @properties = @search.result.paginate(page: params[:page], per_page: 16)
        @search.sorts = ['photos_count desc', 'updated_at desc', 'availability_date asc', 'name desc', 'bedrooms asc'] if @search.sorts.empty?
        @arrProperties = @properties.to_a

        # List lead_properties
        @lead_properties = @lead.lead_properties.map(&:property_id).uniq #Array of unique property_ids in lead_properties list
        @selected_properties = Property.where(id: @lead_properties)
        @phase = Phase.find(2)

        flash.now[:info] = "Saved."
        respond_to do |format|
          format.js {
            render 'leads/show/step2/done'
          }
          format.html
        end
      else
        flash.now[:alert] = @lead.errors.full_messages.to_sentence
      end

    elsif lead_params[:negotiation_completed]
      if @lead.update(lead_params)
        @phase_updates_p3 = LeadPhase.where("lead_id = ? AND phase_id = ?", @lead.id, 3)
        @properties = Property.joins(:leads).where("\"leads\".\"id\" = ? AND liked_by_lead = ?", @lead.id, true).order("status DESC")
        @phase = Phase.find(3)
        flash.now[:info] = "Saved."
        respond_to do |format|
          format.js {
            render 'leads/show/step3/done'
          }
          format.html
        end
      else
        flash.now[:alert] = @lead.errors.full_messages.to_sentence
      end
    elsif lead_params[:deposit_paid]
      if @lead.update(lead_params)
        flash.now[:info] = "Saved."
        @phase = Phase.find(4)
        respond_to do |format|
          format.js {
            render 'leads/show/step4/done'
          }
          format.html
        end
      else
        flash.now[:alert] = @lead.errors.full_messages.to_sentence
      end
    elsif lead_params[:commission_sorted]
      if @lead.update(lead_params)
        flash.now[:info] = "Saved."
        @phase = Phase.find(5)
        respond_to do |format|
          format.js {
            render 'leads/show/step5/done'
          }
          format.html
        end
      else
        flash.now[:alert] = @lead.errors.full_messages.to_sentence
      end
    end
  end

  def loadmore

    index

    respond_to do |format|
      format.html
      format.js {
        render :template => "leads/index/loadmore.js.erb"
      }
    end
  end

  def loadmore_my_leads
    my_leads

    respond_to do |format|
      format.html
      format.js {
        render "leads/my_leads/loadmore.js.erb"
      }
    end
  end

  def new_from_property
    @property = Property.find(params[:id])
    @location = @property.location
    @area_id = @location.area_id
    @area = Area.find(@area_id)
    @phase = Phase.find(1) #Information collection
    @lead = Lead.new
  end

  def new_from_agent
    @areas = Area.all
    @lead = Lead.new
    respond_to do |format|
      format.js {
        render 'leads/new_from_agent'
      }
      format.html
    end

  end

  def create_from_agent

    new_params = lead_params
    if lead_params[:lead_phases_attributes].blank?
      new_params = lead_params.merge(
        lead_phases_attributes: [phase_id: 1, comment: "You created this lead"],
        user_id: current_user.id
      ).reject{|_, v| v.blank?}
    else
      new_params = lead_params.reject{|_, v| v.blank?}
    end

    @lead = Lead.new(new_params)
    if @lead.save(new_params)
      flash[:info] = "Great job! New lead created successfully."

      redirect_to lead_path(@lead)

    else
      flash[:alert] = @lead.errors.full_messages.to_sentence
      redirect_to my_leads_path
    end

    # IF PHONE VALIDATION IS WANTED
    # @lead = Lead.where("phone = ?", lead_params[:phone]).first_or_initialize
    # if @lead.new_record?
    #
    # else
    #   flash[:alert] = "It looks like someone is already taking care of that client. Please, contact your manager to check what to do next."
    #   redirect_to my_leads_path
    # end

  end

  def edit_field
    @lead = Lead.find(params[:lead_id])
    render partial: "leads/show/edit_field/#{params[:attribute]}"
  end

  def update_field
    new_params = lead_params
    if params[:cancel]

    elsif params[:save]

      Resque.remove_delayed(CheckInDateNotification, :lead_id => @lead.id) if @lead.dropped == true
      LeadMailer.check_in_date_reminder(@lead.id).unschedule_delivery if @lead.dropped == true


      if lead_params[:user_id]
        if @lead.update(new_params)
          flash.now[:info] = "Saved."
          Resque.enqueue(NewLeadAssignmentNotification, @lead.id, current_user.id)
          LeadMailer.new_assignment(@lead.id, current_user.id).deliver if !@lead.user.blank? && @lead.user.setting.enable_email

          if @lead.check_in_date > Date.today + 21.days && @lead.check_in_date <= Date.today + 30.days
            Resque.enqueue_in(@lead.check_in_date.to_time - Time.now - 1.days, CheckInDateNotification, @lead.id)
            Resque.enqueue_in(@lead.check_in_date.to_time - Time.now - 10.days, CheckInDateNotification, @lead.id)
            LeadMailer.check_in_date_reminder(@lead.id).deliver_in(@lead.check_in_date.to_time - Time.now - 1.days) if !@lead.user.blank? && @lead.user.setting.enable_email
            LeadMailer.check_in_date_reminder(@lead.id).deliver_in(@lead.check_in_date.to_time - Time.now - 10.days) if !@lead.user.blank? && @lead.user.setting.enable_email

          elsif @lead.check_in_date > Date.today + 30.days && @lead.check_in_date <= Date.today + 90.days
            Resque.enqueue_in(@lead.check_in_date.to_time - Time.now - 1.days, CheckInDateNotification, @lead.id)
            Resque.enqueue_in(@lead.check_in_date.to_time - Time.now - 10.days, CheckInDateNotification, @lead.id)
            Resque.enqueue_in(@lead.check_in_date.to_time - Time.now - 30.days, CheckInDateNotification, @lead.id)
            LeadMailer.check_in_date_reminder(@lead.id).deliver_in(@lead.check_in_date.to_time - Time.now - 1.days) if !@lead.user.blank? && @lead.user.setting.enable_email
            LeadMailer.check_in_date_reminder(@lead.id).deliver_in(@lead.check_in_date.to_time - Time.now - 10.days) if !@lead.user.blank? && @lead.user.setting.enable_email
            LeadMailer.check_in_date_reminder(@lead.id).deliver_in(@lead.check_in_date.to_time - Time.now - 30.days) if !@lead.user.blank? && @lead.user.setting.enable_email

          elsif @lead.check_in_date > Date.today + 90.days
            Resque.enqueue_in(@lead.check_in_date.to_time - Time.now - 1.days, CheckInDateNotification, @lead.id)
            Resque.enqueue_in(@lead.check_in_date.to_time - Time.now - 10.days, CheckInDateNotification, @lead.id)
            Resque.enqueue_in(@lead.check_in_date.to_time - Time.now - 45.days, CheckInDateNotification, @lead.id)
            LeadMailer.check_in_date_reminder(@lead.id).deliver_in(@lead.check_in_date.to_time - Time.now - 1.days) if !@lead.user.blank? && @lead.user.setting.enable_email
            LeadMailer.check_in_date_reminder(@lead.id).deliver_in(@lead.check_in_date.to_time - Time.now - 10.days) if !@lead.user.blank? && @lead.user.setting.enable_email
            LeadMailer.check_in_date_reminder(@lead.id).deliver_in(@lead.check_in_date.to_time - Time.now - 45.days) if !@lead.user.blank? && @lead.user.setting.enable_email

          end

        else
          flash.now[:alert] = @lead.errors.full_messages.to_sentence
        end
      else
        if @lead.update(new_params)
          flash.now[:info] = "Saved."
        else
          flash.now[:alert] = @lead.errors.full_messages.to_sentence
        end
      end
    end

    respond_to do |format|
      format.js {
        render template: "leads/show/update_field"
      }
      format.html
    end

  end

  def new_lead_phase1
    render 'leads/show/step1/new_lead_phase'
  end

  def new_lead_phase3
    render 'leads/show/step3/new_lead_phase'
  end

  def new_lead_phase4
    render 'leads/show/step4/new_lead_phase'
  end

  def new_lead_phase5
    render 'leads/show/step5/new_lead_phase'
  end

  def create_lead_phase
    new_params = lead_params
    if params[:cancel]
      @phase_updates_p1 = LeadPhase.where("lead_id = ? AND phase_id = ?", @lead.id, 1).order("created_at DESC").paginate(:page => params[:page], :per_page => 5)
      @phase_updates_p3 = LeadPhase.where("lead_id = ? AND phase_id = ?", @lead.id, 3).order("created_at DESC").paginate(:page => params[:page], :per_page => 5)
      @phase_updates_p4 = LeadPhase.where("lead_id = ? AND phase_id = ?", @lead.id, 4).order("created_at DESC").paginate(:page => params[:page], :per_page => 5)
      @phase_updates_p5 = LeadPhase.where("lead_id = ? AND phase_id = ?", @lead.id, 5).order("created_at DESC").paginate(:page => params[:page], :per_page => 5)
    elsif params[:save]
      if @lead.update(new_params)

        flash.now[:info] = "New update created!"

        # Lead phase updates
        @phase_updates_p1 = LeadPhase.where("lead_id = ? AND phase_id = ?", @lead.id, 1).order("created_at DESC").paginate(:page => params[:page], :per_page => 5)
        @phase_updates_p3 = LeadPhase.where("lead_id = ? AND phase_id = ?", @lead.id, 3).order("created_at DESC").paginate(:page => params[:page], :per_page => 5)
        @phase_updates_p4 = LeadPhase.where("lead_id = ? AND phase_id = ?", @lead.id, 4).order("created_at DESC").paginate(:page => params[:page], :per_page => 5)
        @phase_updates_p5 = LeadPhase.where("lead_id = ? AND phase_id = ?", @lead.id, 5).order("created_at DESC").paginate(:page => params[:page], :per_page => 5)

      else
        flash.now[:alert] = @lead.errors.full_messages.to_sentence
      end
    end

    respond_to do |format|
      format.js {
        render template: "leads/show/create_lead_phase"
      }
      format.html
    end

  end

  def delete_lead_phase
    @lead_phase = LeadPhase.find(params[:lead_phase_id])
    @lead = Lead.find(@lead_phase.lead_id)
    if @lead_phase.destroy
      flash.now[:info] = "Update deleted successfully!"
      @phase_updates_p1 = LeadPhase.where("lead_id = ? AND phase_id = ?", @lead.id, 1).order("created_at DESC").paginate(:page => params[:page], :per_page => 5)
      @phase_updates_p3 = LeadPhase.where("lead_id = ? AND phase_id = ?", @lead.id, 3).order("created_at DESC").paginate(:page => params[:page], :per_page => 5)
      @phase_updates_p4 = LeadPhase.where("lead_id = ? AND phase_id = ?", @lead.id, 4).order("created_at DESC").paginate(:page => params[:page], :per_page => 5)
      @phase_updates_p5 = LeadPhase.where("lead_id = ? AND phase_id = ?", @lead.id, 5).order("created_at DESC").paginate(:page => params[:page], :per_page => 5)

    else
      flash.now[:alert] = @lead_phase.errors.full_messages.to_sentence
    end
    respond_to do |format|
      format.js {
        render template: "leads/show/create_lead_phase"
      }
      format.html
    end

  end

  def edit_lead_phase
    @lead_phase = LeadPhase.find(params[:lead_phase_id])
    render 'leads/show/edit_lead_phase'
  end

  def update_lead_phase

    @lead = Lead.find(LeadPhase.find(params[:id]).lead_id)
    @lead_phase = LeadPhase.find(params[:id])

    new_params = params[:lead_phase]

    if params[:cancel]
      @phase_updates_p1 = LeadPhase.where("lead_id = ? AND phase_id = ?", @lead.id, 1).order("created_at DESC").paginate(:page => params[:page], :per_page => 5)
      @phase_updates_p3 = LeadPhase.where("lead_id = ? AND phase_id = ?", @lead.id, 3).order("created_at DESC").paginate(:page => params[:page], :per_page => 5)
      @phase_updates_p4 = LeadPhase.where("lead_id = ? AND phase_id = ?", @lead.id, 4).order("created_at DESC").paginate(:page => params[:page], :per_page => 5)
      @phase_updates_p5 = LeadPhase.where("lead_id = ? AND phase_id = ?", @lead.id, 5).order("created_at DESC").paginate(:page => params[:page], :per_page => 5)

    elsif params[:save]
      if @lead_phase.update(comment: new_params[:comment])

        flash.now[:info] = "Saved!"

        # Lead phase updates
        @phase_updates_p1 = LeadPhase.where("lead_id = ? AND phase_id = ?", @lead.id, 1).order("created_at DESC").paginate(:page => params[:page], :per_page => 5)
        @phase_updates_p3 = LeadPhase.where("lead_id = ? AND phase_id = ?", @lead.id, 3).order("created_at DESC").paginate(:page => params[:page], :per_page => 5)
        @phase_updates_p4 = LeadPhase.where("lead_id = ? AND phase_id = ?", @lead.id, 4).order("created_at DESC").paginate(:page => params[:page], :per_page => 5)
        @phase_updates_p5 = LeadPhase.where("lead_id = ? AND phase_id = ?", @lead.id, 5).order("created_at DESC").paginate(:page => params[:page], :per_page => 5)

      else
        flash.now[:alert] = @lead_phase.errors.full_messages.to_sentence
      end
    end

    respond_to do |format|
      format.js {
        render template: "leads/show/create_lead_phase"
      }
      format.html
    end

  end

  def create_lead_property

    new_params = lead_params
    if params[:save]
      if @lead.update(new_params)

        flash.now[:info] = "Property selected!"

        @lead_areas = @lead.lead_areas.map(&:area_id).uniq
        @areas = Area.where(id: @lead_areas)
        @lead_locations = @lead.lead_locations.map(&:location_id).uniq
        @locations = Location.where(id: @lead_locations)

        # List all properties according to lead's specs

        @all_properties = Property.where(sold: [nil, false])

        if @locations.length > 0
          @search = @all_properties.where(location_id: [@locations.map{|l| l.id}], contract_type: @lead.contract_type).ransack(params[:q])
        else
          @search = @all_properties.where(area_id: [@areas.map{|a| a.id}], contract_type: @lead.contract_type).ransack(params[:q])
        end

        if params[:q].present?
          @search = @all_properties.ransack(params[:q])
        end

        @search.sorts = ['updated_at desc', 'availability_date asc', 'bedrooms asc'] if @search.sorts.empty?

        @properties = @search.result.paginate(page: params[:page], per_page: 16)
        @arrProperties = @properties.to_a
        @q = params[:q].to_unsafe_h if params[:q].present?

        # List lead_properties
        @lead_properties = @lead.lead_properties.map(&:property_id).uniq #Array of unique property_ids in lead_properties list
        @selected_properties = Property.where(id: @lead_properties)

      else
        flash.now[:alert] = @lead.errors.full_messages.to_sentence
      end
    end
    respond_to do |format|
      format.js {
        render "leads/show/lead_properties", properties: @arrProperties, q: @q, search: @search
      }
      format.html
    end

  end

  def delete_lead_property
    @lead_properties = LeadProperty.find(params[:lead_property_id])
    @lead = Lead.find(@lead_properties.first.lead_id)
    if @lead_properties.each(&:destroy)
      flash.now[:info] = "Property removed from suggestions list!"

      @lead_areas = @lead.lead_areas.map(&:area_id).uniq
      @areas = Area.where(id: @lead_areas)
      @lead_locations = @lead.lead_locations.map(&:location_id).uniq
      @locations = Location.where(id: @lead_locations)

      @all_properties = Property.where(sold: [nil, false])

      if @locations.length > 0
        @search = @all_properties.where(location_id: [@locations.map{|l| l.id}], contract_type: @lead.contract_type).ransack(params[:q])
      else
        @search = @all_properties.where(area_id: [@areas.map{|a| a.id}], contract_type: @lead.contract_type).ransack(params[:q])
      end

      if params[:q].present?
        @search = @all_properties.ransack(params[:q])
      end

      @search.sorts = ['updated_at desc', 'availability_date asc', 'bedrooms asc'] if @search.sorts.empty?
      @properties = @search.result.paginate(page: params[:page], per_page: 16)

      @arrProperties = @properties.to_a
      @q = params[:q].to_unsafe_h if params[:q].present?

      @lead_properties = @lead.lead_properties.map(&:property_id).uniq
      @selected_properties = Property.where(id: @lead_properties)

    else
      flash.now[:alert] = @lead_property.errors.full_messages.to_sentence
    end
    respond_to do |format|
      format.js {
        render "leads/show/lead_properties", properties: @arrProperties, q: @q
      }
      format.html
    end

  end

  def update_lead_property

    @lead_property = LeadProperty.find(params[:lead_property_id])
    @lead = Lead.find(@lead_property.lead_id)

    if params[:shared_with_lead]
      if @lead_property.update(shared_with_lead: params[:shared_with_lead], status: params[:status])
        @lead_properties = @lead.lead_properties.map(&:property_id).uniq
        @selected_properties = Property.where(id: @lead_properties)
        @properties = Property.joins(:leads).where("\"leads\".\"id\" = ? AND liked_by_lead = ? AND status != ?", @lead.id, true, 5).order("status DESC")


        flash.now[:info] = "Saved."

        respond_to do |format|
          format.js {
            render template: "leads/show/lead_suggestions"
          }
          format.html
        end

      else
        flash.now[:alert] = @lead_property.errors.full_messages.to_sentence
      end
    elsif params[:liked_by_lead]
      if @lead_property.update(liked_by_lead: params[:liked_by_lead], status: params[:status])
        @lead_properties = @lead.lead_properties.map(&:property_id).uniq
        @selected_properties = Property.where(id: @lead_properties)
        @properties = Property.joins(:leads).where("\"leads\".\"id\" = ? AND liked_by_lead = ? AND status != ?", @lead.id, true, 1).order("status DESC")

        flash.now[:info] = "Saved."

        respond_to do |format|
          format.js {
            render template: "leads/show/lead_suggestions"
          }
          format.html
        end

      else
        flash.now[:alert] = @lead_property.errors.full_messages.to_sentence
      end
    elsif params[:visited_by_lead]
      if @lead_property.update(visited_by_lead: params[:visited_by_lead], status: params[:status])
        @lead_properties = @lead.lead_properties.map(&:property_id).uniq
        @selected_properties = Property.where(id: @lead_properties)
        @properties = Property.joins(:leads).where("\"leads\".\"id\" = ? AND liked_by_lead = ? AND status != ?", @lead.id, true, 1).order("status DESC")

        flash.now[:info] = "Saved."

        respond_to do |format|
          format.js {
            render template: "leads/show/lead_suggestions"
          }
          format.html
        end

      else
        flash.now[:alert] = @lead_property.errors.full_messages.to_sentence
      end

    elsif params[:deposit_paid]
      if @lead_property.update(deposit_paid: params[:deposit_paid], status: params[:status])
        @properties = Property.joins(:leads).where("\"leads\".\"id\" = ? AND status >= ?", @lead.id, 8).order("updated_at DESC")

        if @lead_property.deposit_paid == true
          flash.now[:info] = "Awesome! Keep up with the great work!"
        else
          flash.now[:info] = "Update saved!"
        end

        if @lead_property.deposit_paid == true && !@lead.user_id.blank?
          Resque.enqueue(DepositPaidNotification, @lead.id, @lead_property.id)
          if !@lead_property.contract_end_date.blank?
            @property = Property.find(@lead_property.property_id)
            if @property.update(:availability_date => @lead_property.contract_end_date)
              flash.now[:info] = "Awesome! Keep up with the great work!"
            else
              flash.now[:alert] = @property.errors.full_messages.to_sentence
            end
          end
        end

        respond_to do |format|
          format.js {
            render template: "leads/show/step4/selected_properties"
          }
          format.html
        end

      else
        flash.now[:alert] = @lead_property.errors.full_messages.to_sentence
      end

    else
      if @lead_property.update(status: params[:status])

        # COMMENTED TO CHECK IF THIS IS BETTER IN TERMS OF USABILITY
        # if params[:status] = "Proposal approved"
        #   @lead.update(negotiation_completed: true, information_collected: true, property_found: true)
        # end

        @lead_properties = @lead.lead_properties.map(&:property_id).uniq
        @selected_properties = Property.where(id: @lead_properties)
        @properties = Property.joins(:leads).where("\"leads\".\"id\" = ? AND liked_by_lead = ? AND status != ?", @lead.id, true, 1).order("status DESC")

        flash.now[:info] = "Saved."

        respond_to do |format|
          format.js {
            render template: "leads/show/lead_suggestions"
          }
          format.html
        end

      else
        flash.now[:alert] = @lead_property.errors.full_messages.to_sentence
      end
    end

  end

  def add_property_address
    @property = Property.find(params[:property_id])
    render 'leads/show/step3/add_property_address'
  end

  def property_address

    @property = Property.find(params[:property_id])
    if params[:cancel]
      @properties = Property.joins(:leads).where("\"lead_properties\".\"lead_id\" = ? AND liked_by_lead = ? AND status != ?", @lead.id, true, 1).order("status DESC")
      respond_to do |format|
        format.js {
          render template: 'leads/show/step3/selected_properties'
        }
        format.html
      end
    else
      if @property.update_attribute("address", params[:property][:address])
        flash.now[:info] = "Address added successfully."
        @properties = Property.joins(:leads).where("\"lead_properties\".\"lead_id\" = ? AND liked_by_lead = ? AND status != ?", @lead.id, true, 1).order("status DESC")
        respond_to do |format|
          format.js {
            render template: 'leads/show/step3/selected_properties'
          }
          format.html
        end
      else
        flash.now[:alert] = @property.errors.full_messages.to_sentence
        render 'shared/_message_js'
      end

    end

  end

  def add_meeting_point
    @property = Property.find(params[:property_id])
    @lead_property = LeadProperty.find(params[:lead_property_id])
    render 'leads/show/step3/add_meeting_point'
  end

  def meeting_point

    @lead_property = LeadProperty.find(params[:lead_property_id])
    if params[:cancel]
      @properties = Property.joins(:leads).where("\"lead_properties\".\"lead_id\" = ? AND liked_by_lead = ? AND status != ?", @lead.id, true, 1).order("status DESC")
      respond_to do |format|
        format.js {
          render template: 'leads/show/step3/selected_properties'
        }
        format.html
      end
    else

      if @lead_property.update(meeting_point: params[:lead_property][:meeting_point])
        flash.now[:info] = "Meeting point added successfully."
        @properties = Property.joins(:leads).where("\"lead_properties\".\"lead_id\" = ? AND liked_by_lead = ? AND status != ?", @lead.id, true, 1).order("status DESC")
        respond_to do |format|
          format.js {
            render template: 'leads/show/step3/selected_properties'
          }
          format.html
        end
      else
        flash.now[:alert] = @property.errors.full_messages.to_sentence
        render 'shared/_message_js'
      end
    end
  end

  def add_proposal_amount
    @property = Property.find(params[:property_id])
    @lead_property = LeadProperty.find(params[:lead_property_id])
    render 'leads/show/step3/add_proposal_amount'
  end

  def proposal_amount

    @lead_property = LeadProperty.find(params[:lead_property_id])

    if params[:cancel]
      @properties = Property.joins(:leads).where("\"lead_properties\".\"lead_id\" = ? AND liked_by_lead = ? AND status != ?", @lead.id, true, 1).order("status DESC")
      respond_to do |format|
        format.js {
          render template: 'leads/show/step3/selected_properties'
        }
        format.html
      end
    else

      if @lead_property.update(proposal_amount: params[:lead_property][:proposal_amount])
        flash.now[:info] = "Congratulations for getting that proposal!"
        @properties = Property.joins(:leads).where("\"lead_properties\".\"lead_id\" = ? AND liked_by_lead = ? AND status != ?", @lead.id, true, 1).order("status DESC")
        respond_to do |format|
          format.js {
            render template: 'leads/show/step3/selected_properties'
          }
          format.html
        end
      else
        flash.now[:alert] = @property.errors.full_messages.to_sentence
        render 'shared/_message_js'
      end
    end
  end

  def add_visit_date
    @property = Property.find(params[:property_id])
    @lead_property = LeadProperty.find(params[:lead_property_id])
    render 'leads/show/step3/add_visit_date'
  end

  def visit_date

    @lead_property = LeadProperty.find(params[:lead_property_id])
    if params[:cancel]
      @properties = Property.joins(:leads).where("\"lead_properties\".\"lead_id\" = ? AND liked_by_lead = ? AND status != ?", @lead.id, true, 1).order("status DESC")
      respond_to do |format|
        format.js {
          render template: 'leads/show/step3/selected_properties'
        }
        format.html
      end
    else

      if @lead_property.update(visit_date: params[:lead_property][:visit_date])
        flash.now[:info] = "Great job! A reminder will be sent on the date of your visit."
        @properties = Property.joins(:leads).where("\"lead_properties\".\"lead_id\" = ? AND liked_by_lead = ? AND status != ?", @lead.id, true, 1).order("status DESC")
        if !@lead_property.visit_date.blank?
          Resque.enqueue_in(@lead_property.visit_date.to_time - Time.now, VisitDateNotification, @lead.id, @lead_property.id)
          if !@lead.user_id.blank?
            LeadMailer.visit_date(@lead.id, @lead_property.id).deliver_in(@lead_property.visit_date.to_time - Time.now) if !@lead.user.blank? && @lead.user.setting.enable_email
          end
        end
        respond_to do |format|
          format.js {
            render template: 'leads/show/step3/selected_properties'
          }
          format.html
        end
      else
        flash.now[:alert] = @property.errors.full_messages.to_sentence
        render 'shared/_message_js'
      end
    end
  end

  def edit_deposit_info
    @property = Property.find(params[:property_id])
    @lead_property = LeadProperty.find(params[:lead_property_id])
    @attribute = params[:attribute]
    render "leads/show/step4/edit_deposit_info"
  end

  def update_deposit_info
    @lead_property = LeadProperty.find(params[:lead_property_id])
    if params[:cancel]
      @properties = Property.joins(:leads).where("\"leads\".\"id\" = ? AND status >= ?", @lead.id, 8).order("updated_at DESC")
      respond_to do |format|
        format.js {
          render "leads/show/step4/update_deposit_info", locals: {attribute: params[:attribute], property: @lead_property.property_id, lead_property: @lead_property}
        }
        format.html
      end
    else
      if @lead_property.update_attribute(params[:attribute], params[:lead_property][params[:attribute]])
        flash.now[:info] = "Saved."
        @properties = Property.joins(:leads).where("\"leads\".\"id\" = ? AND status >= ?", @lead.id, 8).order("updated_at DESC")
        if params[:attribute] == 'contract_signature_date' && !@lead_property.contract_signature_date.blank?
          Resque.enqueue_in(@lead_property.contract_signature_date.to_time - Time.now - 1.day, DayBeforeContractSignatureDateNotification, @lead.id, @lead_property.id)
          Resque.enqueue_in(@lead_property.contract_signature_date.to_time - Time.now, ContractSignatureDateNotification, @lead.id, @lead_property.id)
          if !@lead.user_id.blank?
            LeadMailer.contract_date(@lead.id, @lead_property.id).deliver_in(@lead_property.contract_signature_date.to_time - Time.now) if !@lead.user.blank? && @lead.user.setting.enable_email
          end
        end
        respond_to do |format|
          format.js {
            render "leads/show/step4/update_deposit_info", locals: {attribute: params[:attribute], property: @lead_property.property_id, lead_property: @lead_property}
          }
          format.html
        end
      else
        flash.now[:alert] = @property.errors.full_messages.to_sentence
        render 'shared/_message_js'
      end
    end

  end

  def edit_contract_info
    @property = Property.find(params[:property_id])
    @lead_property = LeadProperty.find(params[:lead_property_id])
    @attribute = params[:attribute]
    render "leads/show/step5/edit_contract_info"
  end

  def update_contract_info
    @lead_property = LeadProperty.find(params[:lead_property_id])
    if params[:cancel]
      @properties = Property.joins(:leads).where("\"leads\".\"id\" = ? AND status >= ?", @lead.id, 9).order("updated_at DESC")
      respond_to do |format|
        format.js {
          render "leads/show/step5/update_contract_info", locals: {attribute: params[:attribute], property: @lead_property.property_id, lead_property: @lead_property}
        }
        format.html
      end
    elsif params[:attribute]
      if @lead_property.update_attribute(params[:attribute], params[:lead_property][params[:attribute]])
        flash.now[:info] = "Saved."
        @properties = Property.joins(:leads).where("\"leads\".\"id\" = ? AND status >= ?", @lead.id, 9).order("updated_at DESC")
        respond_to do |format|
          format.js {
            render "leads/show/step5/update_contract_info", locals: {attribute: params[:attribute], property: @lead_property.property_id, lead_property: @lead_property}
          }
          format.html
        end
      else
        flash.now[:alert] = @property.errors.full_messages.to_sentence
        render 'shared/_message_js'
      end

    elsif params[:contract_stage]
      if @lead_property.update_attribute(params[:contract_stage], params[:contract_stage_value])
        flash.now[:info] = "Saved."
        @properties = Property.joins(:leads).where("\"leads\".\"id\" = ? AND status >= ?", @lead.id, 9).order("updated_at DESC")

        if params[:contract_stage] == "contract_signed"
          if !@lead.user_id.blank? && @lead_property.contract_signed == true
            Resque.enqueue(ContractSignedNotification, @lead.id, @lead_property.id)
            @lead.update_attribute('contract_signed', true)
          elsif !@lead.user_id.blank? && @lead_property.contract_signed == false
            @lead.update_attribute('contract_signed', false)
          end
        end

        if params[:contract_stage] == "commission_paid"
          if !@lead.user_id.blank? && @lead_property.commission_paid == true
            Resque.enqueue(CommissionPaidNotification, @lead.id, @lead_property.id)
            @lead.update_attribute('commission_paid', true)
          elsif !@lead.user_id.blank? && @lead_property.commission_paid == false
            @lead.update_attribute('commission_paid', false)
          end
        end

        if params[:contract_stage] == "commission_sorted"
          if !@lead.user_id.blank? && @lead_property.commission_sorted == true
            Resque.enqueue(CommissionSortedNotification, @lead.id, @lead_property.id)
            @lead.update_attribute('commission_sorted', true)
          elsif !@lead.user_id.blank? && @lead_property.commission_sorted == false
            @lead.update_attribute('commission_sorted', false)
          end
        end

        respond_to do |format|
          format.js {
            render "leads/show/step5/update_contract_info", locals: {attribute: params[:contract_stage], property: @lead_property.property_id, lead_property: @lead_property}
          }
          format.html
        end
      else
        flash.now[:alert] = @property.errors.full_messages.to_sentence
        render 'shared/_message_js'
      end

    end

  end


  def create_lead_location

    new_params = lead_params
    if params[:save]
      if @lead.update(new_params)

        flash.now[:info] = "Location added!"
        @lead_areas = @lead.lead_areas.map(&:area_id).uniq
        @areas = Area.where(id: @lead_areas)
        @lead_locations = @lead.lead_locations.map(&:location_id).uniq
        @locations = Location.where(id: @lead_locations)

      else
        flash.now[:alert] = @lead.errors.full_messages.to_sentence
      end
    end
    respond_to do |format|
      format.js {
        render template: "leads/show/lead_locations"
      }
      format.html
    end

  end

  def delete_lead_location
    @lead_location = LeadLocation.where("location_id = ? AND lead_id = ?", params[:lead_location_id], params[:lead_id])
    @lead = Lead.find(@lead_location.first.lead_id)
    if @lead_location.each(&:destroy)
      flash.now[:info] = "Location removed!"
      @lead_areas = @lead.lead_areas.map(&:area_id).uniq
      @areas = Area.where(id: @lead_areas)
      @lead_locations = @lead.lead_locations.map(&:location_id).uniq
      @locations = Location.where(id: @lead_locations)
    else
      flash.now[:alert] = @lead_location.errors.full_messages.to_sentence
    end
    respond_to do |format|
      format.js {
        render template: "leads/show/lead_locations"
      }
      format.html
    end

  end

  def create_reason_for_dropping
    render 'leads/show/create_reason_for_dropping', lead: @lead.id
  end

  def drop_lead

    if params[:cancel]
      render 'leads/show/cancel_drop_lead'
    else
      if @lead.update(:dropped => true, :user_id => nil, :dropped_by_id => current_user.id, :reason_for_dropping => lead_params[:reason_for_dropping])
        flash[:info] = "Lead dropped!"
        if @lead.user_id == current_user.id
          Resque.enqueue(LeadDroppedNotification, @lead.id, current_user.id)
        end

      else
        flash[:alert] = @lead.errors.full_messages.to_sentence
      end

      render 'leads/show/drop_lead'

    end

  end

  def my_leads

    params[:check_in_date] ||= Date.current.to_s
    @my_leads = Lead.where(dropped: [false, nil], user_id: current_user.id)

    if params[:q].present?
      params[:check_in_date] = params[:q][:check_in_date]
      params[:user_id] = params[:q][:user_id]
      params[:contract_type] = params[:q][:contract_type]
    end

    @search = @my_leads.ransack(params[:q])

    if params[:check_in_date].nil?
      params[:check_in_date] ||= Date.current.to_s
    end

    check_in_date = Date.parse(params[:check_in_date])
    first_of_month = (check_in_date).beginning_of_month
    end_of_month = (check_in_date).end_of_month

    if params[:user_id].present?
      @user_leads = @my_leads.where('(check_in_date BETWEEN ? AND ?) AND user_id = ?', first_of_month, end_of_month, params[:user_id])
    else
      @user_leads = @my_leads.where('check_in_date BETWEEN ? AND ?', first_of_month, end_of_month)
    end

    if params[:contract_type].present?
      @leads = @user_leads.where('contract_type = ?', params[:contract_type]).joins(:user).select(
        :first_name,
        "\"leads\".\"id\"",
        :name,
        :check_in_date,
        :contract_type,
        :created_at,
        :updated_at,
        :information_collected,
        :property_found,
        :negotiation_completed,
        :deposit_paid,
        :contract_signed,
        :commission_paid,
        :budget,
        :contract_period,
        :bedrooms,
        :property_type,
        :no_of_people,
        :nationality,
        :description,
        :user_id
      )
    else
      @leads = @user_leads.joins(:user).select(:first_name).select(
        :first_name,
        "\"leads\".\"id\"",
        :name,
        :check_in_date,
        :contract_type,
        :created_at,
        :updated_at,
        :information_collected,
        :property_found,
        :negotiation_completed,
        :deposit_paid,
        :contract_signed,
        :commission_paid,
        :budget,
        :contract_period,
        :bedrooms,
        :property_type,
        :no_of_people,
        :nationality,
        :description,
        :user_id
      )
    end

    @search_table = @leads.ransack(params[:q])
    @search_table.sorts = ['check_in_date asc'] if @search_table.sorts.empty?
    @leads_list = @search_table.result.paginate(page: params[:page], per_page: 5)
    @arrLeads = @leads_list.to_a
    @q = params[:q].to_unsafe_h if params[:q].present?


    @visits = LeadProperty.where('(visit_date BETWEEN ? AND ?)', first_of_month, end_of_month).where(
      lead_id: [Lead.where(user_id: current_user.id)]
    ).joins(:lead).joins(:property).select(
      "\"leads\".\"name\"",
      :visit_date,
      :lead_id,
      :property_id,
      :meeting_point,
      :price,
      :address,
      "\"properties\".\"bedrooms\"",
      "\"properties\".\"property_type\""
    )
    @visits_list = @visits.ransack(params[:q]) if @visits.present?

    @contracts = LeadProperty.where('(contract_signature_date BETWEEN ? AND ?)', first_of_month, end_of_month).where(
      lead_id: [Lead.where(user_id: current_user.id)]
    ).joins(:lead).joins(:property).select(
      "\"leads\".\"name\"",
      :contract_signature_date,
      :lead_id,
      :property_id,
      :deposit_for_bills,
      :deposit_amount,
      :contract_amount,
      :premium_amount,
      :deposit_paid,
      :commission_paid,
      :vat_client,
      :vat_owner,
      :address
    )
    @contracts_list = @contracts.ransack(params[:q]) if @contracts.present?


  end

  def search_properties

      @lead_areas = @lead.lead_areas.map(&:area_id).uniq
      @areas = Area.where(id: @lead_areas)
      @lead_locations = @lead.lead_locations.map(&:location_id).uniq
      @locations = Location.where(id: @lead_locations)

      # List all properties according to lead's specs

      @all_properties = Property.where(sold: [nil, false])

      if @locations.length > 0
        @search = @all_properties.where(location_id: [@locations.map{|l| l.id}], contract_type: @lead.contract_type).ransack(params[:q])
      else
        @search = @all_properties.where(area_id: [@areas.map{|a| a.id}], contract_type: @lead.contract_type).ransack(params[:q])
      end

      if params[:q].present?
        @search = @all_properties.ransack(params[:q])
      end

    @search.sorts = ['updated_at desc', 'availability_date asc', 'bedrooms asc'] if @search.sorts.empty?
    @properties = @search.result.paginate(page: params[:page], per_page: 16)
    @arrProperties = @properties.to_a
    @q = params[:q].to_unsafe_h if params[:q].present?

    # List lead_properties
    @lead_properties = @lead.lead_properties.map(&:property_id).uniq #Array of unique property_ids in lead_properties list
    @selected_properties = Property.where(id: @lead_properties)

    respond_to do |format|
      format.js {
        render "leads/show/lead_properties", properties: @arrProperties, q: @q, search: @search
      }
      format.html
    end

  end


  private

  def lead_params
    params.require(:lead).permit(:name, :phone, :email, :contract_type, :contract_period, :property_type,
      :bedrooms, :budget, :description, :check_in_date, :user_id, :no_of_people, :nationality, :pet_friendly,
      :information_collected, :property_found, :negotiation_completed, :deposit_paid, :contract_signed,
      :commission_paid, :commission_sorted, :dropped, :avatar, :phone_country_code, :dropped_by_id,
      :reason_for_dropping, lead_properties_attributes: [:property_id, :status],
      lead_areas_attributes: [:area_id], lead_locations_attributes: [:lead_id, :location_id],
      lead_phases_attributes: [:phase_id, :comment])
  end

  def set_lead
    @lead = Lead.find(params[:id])
  end

  def is_authorized
    redirect_to root_path, alert: "Sorry, you can't access that page" unless current_user.id == @lead.user_id || current_user.role_id == "admin" || current_user.role_id == "manager"
  end

  def set_agent
    #Agent name
    if !@lead.user_id.blank?
      @user = User.find(@lead.user_id)
      if !@user.last_name.blank?
        @user_full_name = User.find(@lead.user_id).first_name.to_s + User.find(@lead.user_id).last_name.to_s
      else
        @user_full_name = User.find(@lead.user_id).first_name.to_s
      end
    end
  end

  def set_locations
    @lead_areas = @lead.lead_areas.map(&:area_id).uniq
    @areas = Area.where(id: @lead_areas)
    @lead_locations = @lead.lead_locations.map(&:location_id).uniq
    @locations = Location.where(id: @lead_locations)
  end

end
