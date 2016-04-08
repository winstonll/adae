# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
Rails.application.config.assets.precompile += %w( landing.css )
Rails.application.config.assets.precompile += %w( items.css )
Rails.application.config.assets.precompile += %w( requests.css )
Rails.application.config.assets.precompile += %w( search.css )
Rails.application.config.assets.precompile += %w( navbar.css )
Rails.application.config.assets.precompile += %w( footer.css )
Rails.application.config.assets.precompile += %w( about.css )
Rails.application.config.assets.precompile += %w( static-pages.css )
Rails.application.config.assets.precompile += %w( conversations.css )
Rails.application.config.assets.precompile += %w( chat.css )
Rails.application.config.assets.precompile += %w( edit-profile.css )
Rails.application.config.assets.precompile += %w( reviews.css )
Rails.application.config.assets.precompile += %w( ratings.css )
Rails.application.config.assets.precompile += %w( contact-us.css )
Rails.application.config.assets.precompile += %w( modals.css )
Rails.application.config.assets.precompile += %w( users.css )
Rails.application.config.assets.precompile += %w( transactions.css )
Rails.application.config.assets.precompile += %w( landing.js )
Rails.application.config.assets.precompile += %w( items.js.erb )
Rails.application.config.assets.precompile += %w( requests.js )
Rails.application.config.assets.precompile += %w( map_description.js )
Rails.application.config.assets.precompile += %w( users.js )
Rails.application.config.assets.precompile += %w( map.js.erb )
Rails.application.config.assets.precompile += %w( requestmap.js.erb )
Rails.application.config.assets.precompile += %w( map_shoutout.js )


