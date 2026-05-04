# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path
# Add Yarn node_modules folder to the asset load path.
Rails.application.config.assets.paths << Rails.root.join('node_modules', 'lib')

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.

# Rails.application.config.assets.precompile += %w( admin.js admin.css )
# Rails.application.config.assets.precompile += %w( vendor/assets/lib/lightbox/* )
# Rails.application.config.assets.precompile += %w( vendor/assets/lib/jquery.waypoints.min.js )
# Rails.application.config.assets.precompile += %w( vendor/assets/lib/jquery.touchSwipe.min.js )
# Rails.application.config.assets.precompile += %w( main.js )
# Rails.application.config.assets.precompile += %w( vendor/assets/rails_admin/custom/ui.js )
Rails.application.config.assets.precompile += %w( editor/editor.scss )
Rails.application.config.assets.precompile += %w( no-photo.png )
Rails.application.config.assets.precompile += %w( direct_uploads.css )
Rails.application.config.assets.precompile += %w( watermark.png )
Rails.application.config.assets.precompile += %w( leads/leads.scss )
Rails.application.config.assets.precompile += %w( leads/leads_internal.scss )
Rails.application.config.assets.precompile += %w( leads/fullcalendar.css )
Rails.application.config.assets.precompile += %w( fullcalendar/jquery.fullcalendar.js )
Rails.application.config.assets.precompile += %w( fullcalendar/jquery.ui-fullcalendar.js )
Rails.application.config.assets.precompile += %w( fullcalendar/fullcalendar.js )
Rails.application.config.assets.precompile += %w( fullcalendar/moment.js )
Rails.application.config.assets.precompile += %w( fullcalendar/fullcalendar.css )
Rails.application.config.assets.precompile += %w( fullcalendar/jquery.easing.js )
Rails.application.config.assets.precompile += %w( fullcalendar/jquery-ui.datepicker.js )
Rails.application.config.assets.precompile += %w( leads/done_button.scss )
Rails.application.config.assets.precompile += %w( hero-bg.jpg )
Rails.application.config.assets.precompile += %w( hero-images/hero-bg-2.jpg )
Rails.application.config.assets.precompile += %w( hero-images/hero-bg-3.jpg )
Rails.application.config.assets.precompile += %w( hero-images/hero-bg-4.jpg )
Rails.application.config.assets.precompile += %w( hero-images/hero-bg-5.jpg )
Rails.application.config.assets.precompile += %w( hero-images/hero-bg-6.jpg )
Rails.application.config.assets.precompile += %w( hero-images/hero-bg-7.jpg )
Rails.application.config.assets.precompile += %w( hero-images/hero-bg-8.jpg )
Rails.application.config.assets.precompile += %w( hero-images/hero-bg-9.jpg )
Rails.application.config.assets.precompile += %w( hero-images/hero-bg-10.jpg )
Rails.application.config.assets.precompile += %w( hero-images/hero-bg-11.jpg )
Rails.application.config.assets.precompile += %w( hero-images/hero-bg-12.jpg )
Rails.application.config.assets.precompile += %w( hero-images/hero-bg-13.jpg )
Rails.application.config.assets.precompile += %w( hero-images/internal-bg-1.jpg )
Rails.application.config.assets.precompile += %w( hero-images/internal-bg-2.jpg )
Rails.application.config.assets.precompile += %w( hero-images/internal-bg-3.jpg )
Rails.application.config.assets.precompile += %w( hero-images/internal-bg-4.jpg )
Rails.application.config.assets.precompile += %w( hero-images/internal-bg-5.jpg )
Rails.application.config.assets.precompile += %w( hero-images/internal-bg-6.jpg )

# CAREERS
Rails.application.config.assets.precompile += %w( candidates/candidates.scss )
Rails.application.config.assets.precompile += %w( careers/candidates-header.jpg )
Rails.application.config.assets.precompile += %w( careers/our-team.jpg )
Rails.application.config.assets.precompile += %w( careers/our-values-bg.jpg )

Rails.application.config.assets.precompile += %w( careers/our-values-agility.jpg )
Rails.application.config.assets.precompile += %w( careers/our-values-care.jpg )
Rails.application.config.assets.precompile += %w( careers/our-values-diversity.jpg )
Rails.application.config.assets.precompile += %w( careers/our-values-honesty.jpg )
Rails.application.config.assets.precompile += %w( careers/our-values-openness.jpg )
Rails.application.config.assets.precompile += %w( careers/our-values-partnership.jpg )
Rails.application.config.assets.precompile += %w( careers/our-values-respect.jpg )
Rails.application.config.assets.precompile += %w( careers/our-values-simple.jpg )

Rails.application.config.assets.precompile += %w( careers/careers-commission.png )
Rails.application.config.assets.precompile += %w( careers/careers-hours.png )
Rails.application.config.assets.precompile += %w( careers/careers-training.png )
Rails.application.config.assets.precompile += %w( careers/careers-workplace.png )

# ROCKLAND
Rails.application.config.assets.precompile += %w( watermark-rockland.png )
Rails.application.config.assets.precompile += %w( application_rockland.scss )
