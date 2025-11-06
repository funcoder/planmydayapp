# Load Stripe gem
begin
  require 'stripe'
rescue LoadError => e
  Rails.logger.error "Failed to load Stripe gem: #{e.message}"
  raise
end

# Stripe configuration
Rails.configuration.stripe = {
  publishable_key: ENV['STRIPE_PUBLISHABLE_KEY'],
  secret_key: ENV['STRIPE_SECRET_KEY'],
  signing_secret: ENV['STRIPE_WEBHOOK_SECRET']
}

# Only set API key if we have credentials
if Rails.configuration.stripe[:secret_key].present?
  Stripe.api_key = Rails.configuration.stripe[:secret_key]
else
  Rails.logger.warn "Stripe secret key not set. Stripe functionality will not work."
end

# Stripe Price IDs for subscription products
# These should be set in your environment variables after creating products in Stripe Dashboard
STRIPE_PRO_PRICE_ID = ENV['STRIPE_PRO_PRICE_ID'] || 'price_1234567890' # Replace with actual price ID from Stripe ($5/month recurring)
STRIPE_LIFETIME_PRICE_ID = ENV['STRIPE_LIFETIME_PRICE_ID'] || 'price_0987654321' # Replace with actual price ID from Stripe ($49.99 one-time)
