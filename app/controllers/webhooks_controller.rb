class WebhooksController < ApplicationController
  allow_unauthenticated_access
  skip_before_action :verify_authenticity_token

  def stripe
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    endpoint_secret = Rails.configuration.stripe[:signing_secret]

    begin
      event = Stripe::Webhook.construct_event(
        payload, sig_header, endpoint_secret
      )
    rescue JSON::ParserError => e
      render json: { error: 'Invalid payload' }, status: 400
      return
    rescue Stripe::SignatureVerificationError => e
      render json: { error: 'Invalid signature' }, status: 400
      return
    end

    # Handle the event
    case event.type
    when 'checkout.session.completed'
      handle_checkout_session_completed(event.data.object)
    when 'customer.subscription.updated'
      handle_subscription_updated(event.data.object)
    when 'customer.subscription.deleted'
      handle_subscription_deleted(event.data.object)
    when 'invoice.payment_succeeded'
      handle_invoice_payment_succeeded(event.data.object)
    when 'invoice.payment_failed'
      handle_invoice_payment_failed(event.data.object)
    else
      Rails.logger.info "Unhandled event type: #{event.type}"
    end

    render json: { message: 'success' }
  end

  private

  def handle_checkout_session_completed(session)
    Rails.logger.info "Handling checkout.session.completed for customer: #{session.customer}"

    user = User.find_by(stripe_customer_id: session.customer)

    unless user
      Rails.logger.error "No user found with stripe_customer_id: #{session.customer}"
      return
    end

    subscription = Stripe::Subscription.retrieve(session.subscription)
    Rails.logger.info "Retrieved subscription: #{subscription.id}"

    user.update(
      stripe_subscription_id: subscription.id,
      subscription_tier: 'pro',
      subscription_status: 'active',
      subscription_period_end: Time.at(subscription.current_period_end)
    )

    Rails.logger.info "Subscription activated for user #{user.id} (#{user.email_address})"
  rescue => e
    Rails.logger.error "Error in handle_checkout_session_completed: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
  end

  def handle_subscription_updated(subscription)
    user = User.find_by(stripe_customer_id: subscription.customer)
    return unless user

    # Determine status
    status = case subscription.status
             when 'active' then subscription.cancel_at_period_end ? 'cancelling' : 'active'
             when 'past_due' then 'past_due'
             when 'canceled' then 'cancelled'
             when 'unpaid' then 'unpaid'
             else 'inactive'
             end

    # Keep user on Pro if subscription is still active (even if cancelling)
    tier = (subscription.status == 'active') ? 'pro' : 'free'

    updates = {
      subscription_status: status,
      subscription_tier: tier,
      subscription_period_end: Time.at(subscription.current_period_end)
    }

    # Clear subscription IDs only if subscription is fully cancelled
    if subscription.status == 'canceled'
      updates[:stripe_subscription_id] = nil
    end

    user.update(updates)

    Rails.logger.info "Subscription updated for user #{user.id}: #{status}, tier: #{tier}"
  end

  def handle_subscription_deleted(subscription)
    user = User.find_by(stripe_customer_id: subscription.customer)
    return unless user

    # This event fires when subscription actually ends (after period end)
    user.update(
      subscription_tier: 'free',
      subscription_status: 'cancelled',
      stripe_subscription_id: nil,
      subscription_period_end: nil
    )

    Rails.logger.info "Subscription ended for user #{user.id} - downgraded to free tier"
  end

  def handle_invoice_payment_succeeded(invoice)
    user = User.find_by(stripe_customer_id: invoice.customer)
    return unless user

    # On successful payment, update period end and ensure subscription is active
    if invoice.subscription.present?
      subscription = Stripe::Subscription.retrieve(invoice.subscription)
      user.update(
        subscription_status: 'active',
        subscription_tier: 'pro',
        subscription_period_end: Time.at(subscription.current_period_end)
      )
    end

    Rails.logger.info "Payment succeeded for user #{user.id}"
    # Could send a receipt email here
  end

  def handle_invoice_payment_failed(invoice)
    user = User.find_by(stripe_customer_id: invoice.customer)
    return unless user

    user.update(subscription_status: 'past_due')
    Rails.logger.warn "Payment failed for user #{user.id}"
    # Could send a payment failure email here
  end
end
