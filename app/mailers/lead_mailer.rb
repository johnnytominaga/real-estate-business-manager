include ActionView::Helpers::UrlHelper

class LeadMailer < ApplicationMailer

  def new_lead(lead)
    @lead = Lead.find(lead)

    @lead_areas = LeadArea.where("lead_id = ?", @lead.id)
    if !@lead_areas.blank?
      @lead_unique_areas = @lead_areas.map(&:area_id).uniq
    end
    @lead_locations = LeadLocation.where("lead_id = ?", @lead.id)
    if !@lead_locations.blank?
      @lead_unique_locations = @lead_locations.map(&:location_id).uniq
    end

    if !@lead.check_in_date.blank?
      @lead_check_in_date = @lead.check_in_date.to_time.strftime("%d/%m/%Y")
    end
    if !@lead.budget.blank?
      @lead_budget = @lead.budget
    end
    if !@lead.contract_type.blank?
      @lead_contract_type = @lead.contract_type
    end
    if !@lead.contract_period.blank?
      if @lead.contract_type == "Rent"
        @lead_contract_period = "(" + @lead.contract_period + ")"
      else
        @lead_contract_period = ""
      end
    end

    @link = link_to("Go to website »", Rails.application.routes.url_helpers.root_url)
    @lead_link = link_to("Go to lead »", Rails.application.routes.url_helpers.lead_url(@lead.id))
    @subject = "New Lead - #{@lead_contract_type} #{@lead_contract_period}: #{@lead.name} has submitted a new request from our standard contact form | #{@lead_budget} | Check in date: #{@lead_check_in_date}"

    mail to: ["ricardo@example.com", "thais@example.com"],
          reply_to: @lead.email,
          bcc: "johnny@example.com",
          subject: @subject

  end



  def new_lead_from_property(lead, lead_property)
    @lead = Lead.find(lead)

    @lead_areas = LeadArea.where("lead_id = ?", @lead.id)
    if !@lead_areas.blank?
      @lead_unique_areas = @lead_areas.map(&:area_id).uniq
    end
    @lead_locations = LeadLocation.where("lead_id = ?", @lead.id)
    if !@lead_locations.blank?
      @lead_unique_locations = @lead_locations.map(&:location_id).uniq
    end

    @lead_property = LeadProperty.find(lead_property)

    if !@lead.check_in_date.blank?
      @lead_check_in_date = @lead.check_in_date.to_time.strftime("%d/%m/%Y")
    end
    if !@lead.budget.blank?
      @lead_budget = @lead.budget
    end
    if !@lead.contract_type.blank?
      @lead_contract_type = @lead.contract_type
    end
    if !@lead.contract_period.blank?
      if @lead.contract_type == "Rent"
        @lead_contract_period = "(" + @lead.contract_period + ")"
      else
        @lead_contract_period = ""
      end
    end

    if !@lead_property.blank?
      @property_id = @lead_property.property_id
      @property_link = link_to("Property ID: #{@lead_property.property_id}", Rails.application.routes.url_helpers.property_url(@lead_property.property_id))
      @lead_link = link_to("Go to lead »", Rails.application.routes.url_helpers.lead_url(@lead.id))
      @subject = "New Lead - #{@lead_contract_type} #{@lead_contract_period}: #{@lead.name} has submitted a new request for Property ID #{@property_id} | #{@lead_budget} | Check in date: #{@lead_check_in_date}"
    else
      @link = link_to("Go to website »", Rails.application.routes.url_helpers.root_url)
      @lead_link = link_to("Go to lead »", Rails.application.routes.url_helpers.lead_url(@lead.id))
      @subject = "New Lead - #{@lead_contract_type} #{@lead_contract_period}: #{@lead.name} has submitted a new request from our standard contact form | #{@lead_budget} | Check in date: #{@lead_check_in_date}"
    end

    mail to: ["ricardo@example.com", "thais@example.com"],
          reply_to: @lead.email,
          bcc: "johnny@example.com",
          subject: @subject

  end

  def existing_lead(lead, lead_property)
    @lead = Lead.find(lead)
    @lead_areas = LeadArea.where("lead_id = ?", @lead.id)
    if !@lead_areas.blank?
      @lead_unique_areas = @lead_areas.map(&:area_id).uniq
    end
    @lead_locations = LeadLocation.where("lead_id = ?", @lead.id)
    if !@lead_locations.blank?
      @lead_unique_locations = @lead_locations.map(&:location_id).uniq
    end

    @lead_property = LeadProperty.find(lead_property)

    @other_lead_properties = LeadProperty.where("lead_id = ? AND property_id != ? AND status != ?", @lead.id, @lead_property.id, 5)
    if !@other_lead_properties.blank?
      @lead_unique_properties = @other_lead_properties.map(&:property_id).uniq
    end

    if !@lead.check_in_date.blank?
      @lead_check_in_date = @lead.check_in_date.to_time.strftime("%d/%m/%Y")
    end
    if !@lead.budget.blank?
      @lead_budget = @lead.budget
    end
    if !@lead.contract_type.blank?
      @lead_contract_type = @lead.contract_type
    end
    if !@lead.contract_period.blank?
      if @lead.contract_type == "Rent"
        @lead_contract_period = "(" + @lead.contract_period + ")"
      else
        @lead_contract_period = ""
      end
    end

    if !@lead_property.blank?
      @property_id = @lead_property.property_id
      @property_link = link_to("Property ID: #{@lead_property.property_id}", Rails.application.routes.url_helpers.property_url(@lead_property.property_id))
      @lead_link = link_to("Go to lead »", Rails.application.routes.url_helpers.lead_url(@lead.id))
      @subject = "Lead - #{@lead_contract_type} #{@lead_contract_period}: #{@lead.name} has submitted a new request for Property ID #{@property_id} | #{@lead_budget} | Check in date: #{@lead_check_in_date}"
    else
      @link = link_to("Go to website »", Rails.application.routes.url_helpers.root_url)
      @lead_link = link_to("Go to lead »", Rails.application.routes.url_helpers.lead_url(@lead.id))
      @subject = "Lead - #{@lead_contract_type} #{@lead_contract_period}: #{@lead.name} has submitted a new request from our standard contact form | #{@lead_budget} | Check in date: #{@lead_check_in_date}"
    end

    mail to: ["ricardo@example.com", "thais@example.com"],
          reply_to: @lead.email,
          bcc: "johnny@example.com",
          subject: @subject

  end

  def new_assignment(lead, manager_id)
    @lead = Lead.find(lead)
    @agent_email = User.find(@lead.user_id).email
    @manager = User.find(manager_id)
    @lead_link = link_to("Go to lead »", Rails.application.routes.url_helpers.lead_url(@lead.id))
    @subject = "You've got a new client: #{@lead.name} assigned to you by #{@manager.fullname}"

    mail to: @agent_email,
          reply_to: @lead.email,
          bcc: "johnny@example.com",
          subject: @subject
  end

  def visit_date(lead_id, lead_property_id)
    @lead = Lead.find(lead_id)
    @lead_property = LeadProperty.find(lead_property_id)
    @property = Property.find(@lead_property.property_id)
    @lead_link = link_to(@lead.name, Rails.application.routes.url_helpers.lead_url(@lead.id))
    @property_link = link_to(@property.property_title, Rails.application.routes.url_helpers.property_url(@property.id))
    @subject = "Reminder: You have a visit today!"

    mail to: @lead.user.email,
          reply_to: @lead.email,
          bcc: "johnny@example.com",
          subject: @subject

  end

  def contract_date(lead_id, lead_property_id)
    @lead = Lead.find(lead_id)
    @lead_property = LeadProperty.find(lead_property_id)
    @property = Property.find(@lead_property.property_id)
    @owner = Owner.find(@property.owner_id)
    @lead_link = link_to(@lead.name, Rails.application.routes.url_helpers.lead_url(@lead.id))
    @property_link = link_to(@property.property_title, Rails.application.routes.url_helpers.property_url(@property.id))
    @subject = "Contract day! Don't forget about your contract with #{@lead.name} today!"

    mail to: @lead.user.email,
          reply_to: @lead.email,
          bcc: "johnny@example.com",
          subject: @subject

  end

  def check_in_date_reminder(lead_id)
    @lead = Lead.find(lead_id)
    @lead_link = link_to(@lead.name, Rails.application.routes.url_helpers.lead_url(@lead.id))
    @subject = "#{@lead.name}'s check in date is getting close. Follow up and start looking for a property!"

    mail to: @lead.user.email,
          reply_to: @lead.email,
          bcc: "johnny@example.com",
          subject: @subject

  end


end
