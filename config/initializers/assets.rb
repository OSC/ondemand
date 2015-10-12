# Add components to asset pipeline
Rails.application.config.assets.paths << Rails.root.join('vendor', 'assets', 'components')

# Precompile image assets not found in app/assets (i.e., vendor/assets)
Rails.application.config.assets.precompile += %w(*.png *.jpg *.jpeg *.gif)