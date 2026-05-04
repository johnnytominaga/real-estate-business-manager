class PropertyMailer < ApplicationMailer
  def remind_to_call(user_id, property_id, owner_id)
    user = User.find_by(id: user_id)
    @property = Property.find(property_id)
    @owner = Owner.find(owner_id)
    @properties = Property.where(owner_id: owner_id)
    if !@owner.name.blank?
      name = @owner.name
    else
      name = @owner.phone_number
    end


    subject = "Reminder: Follow up with #{name} today. This reminder was created from property ID #{@property.id}"

    mail to: user.email,
          reply_to: "admin@example.com",
          bcc: "johnny@example.com",
          subject: subject
  end
end
