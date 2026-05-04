# require 'date_converter'
#
# require 'active_support'
# require 'active_support/core_ext/hash'
#
# require 'open-uri'

# # SEED ROLES IF THEY DON'T EXIST
# ['agent', 'editor', 'manager', 'admin'].each do |role|
#   Role.find_or_create_by!({name: role})
# end
#
# # SEED AREAS IF THEY DON'T EXIST
# ['Sliema & St. Julians area', 'North area', 'Central area', 'South area'].each do |area|
#   Area.find_or_create_by!({area: area})
# end

# SEED AREA SLUGS
# @areas_path = Rails.root.join('db', 'areas.txt')
# open(@areas_path) do |areas|
#   areas.read.each_line do |area|
#     id, slug = area.chomp.split("|")
#     @area = Area.find_by(id: id)
#     @area.update(slug: slug)
#   end
# end

# SEED LOCATION SLUGS
# @location_slugs_path = Rails.root.join('db', 'location_slugs.txt')
# open(@location_slugs_path) do |locations|
#   locations.read.each_line do |location|
#     id, slug = location.chomp.split("|")
#     @location = Location.find_by(id: id)
#     @location.update(slug: slug)
#   end
# end
#
# # SEED LOCATION IF THEY DON'T EXIST
# @locations_path = Rails.root.join('db', 'locations.txt')
# open(@locations_path) do |locations|
#   locations.read.each_line do |location|
#     name, area_id = location.chomp.split("|")
#     Location.create(name: name, area_id: area_id)
#   end
# end

#
# # SEED ADMIN IF IT DOESN'T EXIST
# if User.find_by(:first_name['admin']).blank?
#   User.create(first_name: 'admin', email: 'admin@example.com', password: 'Senha001', password_confirmation: 'Senha001', :role_id => 4 )
# end
#
# # SEED OWNERS
# @owners_path = Rails.root.join('db', 'owners_seed.csv')
# owners = SmarterCSV.process(@owners_path, col_sep: ';')
# Owner.import!(owners)
#
#
# # SEED USERS
# @users_path = Rails.root.join('db', 'users_seed.csv')
# users = SmarterCSV.process(@users_path, col_sep: ';')
# users.each do |user|
#   User.create! user
# end


# SEED PROPERTIES
# @properties_path = Rails.root.join('db', 'properties_seed_dev.csv')
# options = {value_converters: {created_at: DateConverter, updated_at: DateConverter, availability_date: DateConverter}, col_sep: ';'}
# properties = SmarterCSV.process(@properties_path, options)
#
# Property.import!(properties) #import hash of new properties


# SEED PICS

# Property.where("photos_count > 0").each do |property|
#
#   if !property.property_photos.attached?
#     @photos = property.photos_count.to_i
#
#     for i in 1..@photos do
#
#       if i < 10
#         f = i.to_s.rjust(3, '0')
#       else
#         f = i.to_s.rjust(3, '0')
#       end
#
#       if property.old_id.to_i < 10000
#         g = property.old_id.to_s.rjust(5, '0')
#       else
#         g = property.old_id.to_s
#       end
#
#       @photo = open("http://example.com/photos/#{g}/#{g}-#{f}.jpg")
#
#       if File.file?(@photo)
#
#         property.property_photos.attach(
#           io: @photo,
#           filename: "#{g}-#{f}.jpg",
#           content_type: "image/jpg"
#         )
#
#       end
#
#     end
#   end
#
# end

# SEED STATUSES
['Information collection', 'Property hunt', 'Main opportunities', 'Deposit payment', 'Contract signature'].each do |phase|
  Phase.find_or_create_by!({name: phase})
end
