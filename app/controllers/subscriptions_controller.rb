class SubscriptionsController < ApplicationController
  # Allow unauthenticated access to checkout
  # User will either be created during checkout or logged in after

  def new
    # Show subscription page before checkout
    @user = current_user
    @plan = params[:plan] || 'monthly'
  end

  def create
    # Debug: Check if Stripe is defined
    unless defined?(Stripe)
      Rails.logger.error "Stripe constant not defined!"
      redirect_to pricing_path, alert: "Payment system not configured. Please contact support."
      return
    end

    plan_type = params[:plan] || 'monthly'

    Rails.logger.info "Starting Stripe checkout"
    Rails.logger.info "Logged in user: #{current_user&.id || 'none'}"
    Rails.logger.info "Plan type: #{plan_type}"

    # Determine price ID and mode based on plan
    if plan_type == 'lifetime'
      price_id = STRIPE_LIFETIME_PRICE_ID
      mode = 'payment'  # One-time payment
    else
      price_id = STRIPE_PRO_PRICE_ID
      mode = 'subscription'  # Recurring
    end

    Rails.logger.info "Stripe Price ID: #{price_id}"

    # Create Stripe Checkout Session
    begin
      checkout_params = {
        mode: mode,
        line_items: [{
          price: price_id,
          quantity: 1
        }],
        success_url: success_subscriptions_url,
        cancel_url: pricing_url,
        allow_promotion_codes: true,
        metadata: {
          plan_type: plan_type
        }
      }

      # If user is logged in, pre-fill their info
      if current_user
        customer = find_or_create_stripe_customer
        Rails.logger.info "Stripe customer: #{customer.id}"
        checkout_params[:customer] = customer.id
      else
        # Let Stripe collect email during checkout
        Rails.logger.info "No user logged in, Stripe will collect email"
        checkout_params[:customer_email] = nil
      end

      # Create Checkout Session
      session = Stripe::Checkout::Session.create(checkout_params)

      Rails.logger.info "Checkout session created: #{session.id}"
      Rails.logger.info "Redirecting to: #{session.url}"

      redirect_to session.url, allow_other_host: true, status: :see_other
    rescue Stripe::StripeError => e
      Rails.logger.error "Stripe error: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      redirect_to pricing_path, alert: "There was an error processing your request: #{e.message}"
    rescue => e
      Rails.logger.error "Unexpected error: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      redirect_to pricing_path, alert: "An unexpected error occurred. Please try again."
    end
  end

  def success
    # Show success message after successful subscription
    # The webhook will handle updating the user's subscription tier
    @user = current_user
  end

  def manage
    # Show subscription management page
    @user = current_user
  end

  def cancel
    # Show cancellation confirmation page with feedback form
    @user = current_user

    # Check if user is actually Pro
    unless @user.pro? && @user.subscription_status == 'active'
      redirect_to dashboard_path, alert: "No active subscription to cancel."
      return
    end

    # If user is Pro but missing subscription ID, try to find it from Stripe
    if @user.stripe_subscription_id.blank? && @user.stripe_customer_id.present?
      begin
        subscriptions = Stripe::Subscription.list(
          customer: @user.stripe_customer_id,
          limit: 10
        )

        if subscriptions.data.any?
          active_sub = subscriptions.data.find { |s| s.status == 'active' }
          if active_sub
            @user.update(
              stripe_subscription_id: active_sub.id,
              subscription_period_end: Time.at(active_sub.current_period_end)
            )
            Rails.logger.info "Found and stored missing subscription ID: #{active_sub.id}"
          end
        end
      rescue Stripe::StripeError => e
        Rails.logger.error "Error fetching subscription from Stripe: #{e.message}"
      end
    end

    # Final check
    unless @user.stripe_subscription_id.present?
      redirect_to manage_subscriptions_path, alert: "Unable to find your subscription. Please use the Stripe Portal to manage your subscription."
    end
  end

  def process_cancellation
    # Handle subscription cancellation with feedback
    begin
      if current_user.stripe_subscription_id.present?
        # Save cancellation feedback
        if params[:reason].present?
          current_user.cancellation_feedbacks.create(
            reason: params[:reason],
            details: params[:details]
          )
        end

        # Cancel at period end instead of immediately
        subscription = Stripe::Subscription.update(
          current_user.stripe_subscription_id,
          cancel_at_period_end: true
        )

        # Store the period end date and update status
        current_user.update(
          subscription_status: 'cancelling',
          subscription_period_end: Time.at(subscription.current_period_end)
        )

        redirect_to dashboard_path, notice: "Your subscription has been cancelled. You'll continue to have Pro access until #{current_user.subscription_period_end.strftime('%B %d, %Y')}."
      else
        redirect_to dashboard_path, alert: "No active subscription found."
      end
    rescue Stripe::StripeError => e
      redirect_to dashboard_path, alert: "Error cancelling subscription: #{e.message}"
    end
  end

  def reactivate
    # Reactivate a cancelled subscription before period end
    begin
      if current_user.stripe_subscription_id.present? && current_user.subscription_status == 'cancelling'
        # Remove cancel_at_period_end flag
        subscription = Stripe::Subscription.update(
          current_user.stripe_subscription_id,
          cancel_at_period_end: false
        )

        # Update status back to active
        current_user.update(
          subscription_status: 'active'
        )

        redirect_to dashboard_path, notice: "Your subscription has been reactivated. You'll continue to have Pro access."
      else
        redirect_to dashboard_path, alert: "No subscription to reactivate."
      end
    rescue Stripe::StripeError => e
      redirect_to dashboard_path, alert: "Error reactivating subscription: #{e.message}"
    end
  end

  def portal
    # Redirect to Stripe Customer Portal for managing subscription
    begin
      customer = current_user.stripe_customer_id

      if customer.present?
        portal_session = Stripe::BillingPortal::Session.create(
          customer: customer,
          return_url: dashboard_url
        )
        redirect_to portal_session.url, allow_other_host: true
      else
        redirect_to pricing_path, alert: "No subscription found."
      end
    rescue Stripe::StripeError => e
      redirect_to dashboard_path, alert: "Error accessing portal: #{e.message}"
    end
  end

  private

  def find_or_create_stripe_customer
    if current_user.stripe_customer_id.present?
      begin
        Stripe::Customer.retrieve(current_user.stripe_customer_id)
      rescue Stripe::InvalidRequestError
        create_stripe_customer
      end
    else
      create_stripe_customer
    end
  end

  def create_stripe_customer
    customer = Stripe::Customer.create(
      email: current_user.email_address,
      name: current_user.full_name,
      metadata: {
        user_id: current_user.id
      }
    )

    current_user.update(stripe_customer_id: customer.id)
    customer
  end
end
