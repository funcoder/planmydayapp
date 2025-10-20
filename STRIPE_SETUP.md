# Stripe Subscription Setup Guide

This guide will help you set up Stripe payments for PlanMyDay's Pro subscription ($5/month).

## Overview

The subscription system is already implemented with:
- **Free tier**: 5 backlog tasks, no calendar, no sprites
- **Pro tier**: $5/month - unlimited backlog, calendar access, sprites

## Setup Steps

### 1. Create a Stripe Account

1. Go to [https://stripe.com](https://stripe.com) and sign up
2. Complete your account setup
3. Navigate to the Dashboard

### 2. Create a Subscription Product

1. In Stripe Dashboard, go to **Products** → **Add Product**
2. Fill in:
   - **Name**: PlanMyDay Pro
   - **Description**: Access to calendar, sprites, and unlimited backlog tasks
   - **Pricing**: Recurring - $5.00 USD / month
3. Click **Save product**
4. Copy the **Price ID** (starts with `price_...`)

### 3. Get Your API Keys

1. In Stripe Dashboard, go to **Developers** → **API keys**
2. Copy your **Publishable key** (starts with `pk_test_...` or `pk_live_...`)
3. Copy your **Secret key** (starts with `sk_test_...` or `sk_live_...`)

### 4. Set Up Environment Variables

Add these to your `.env` file (for development) and Fly.io secrets (for production):

```bash
STRIPE_PUBLISHABLE_KEY=pk_test_your_key_here
STRIPE_SECRET_KEY=sk_test_your_secret_here
STRIPE_PRO_PRICE_ID=price_your_price_id_here
STRIPE_WEBHOOK_SECRET=whsec_your_webhook_secret_here
```

#### For Development (.env file):
```bash
echo "STRIPE_PUBLISHABLE_KEY=pk_test_..." >> .env
echo "STRIPE_SECRET_KEY=sk_test_..." >> .env
echo "STRIPE_PRO_PRICE_ID=price_..." >> .env
echo "STRIPE_WEBHOOK_SECRET=whsec_..." >> .env
```

#### For Production (Fly.io):
```bash
fly secrets set STRIPE_PUBLISHABLE_KEY=pk_live_...
fly secrets set STRIPE_SECRET_KEY=sk_live_...
fly secrets set STRIPE_PRO_PRICE_ID=price_...
fly secrets set STRIPE_WEBHOOK_SECRET=whsec_...
```

### 5. Set Up Webhooks

Webhooks allow Stripe to notify your app when subscriptions change.

#### Development (using Stripe CLI):
1. Install Stripe CLI: https://stripe.com/docs/stripe-cli
2. Run: `stripe login`
3. Forward webhooks: `stripe listen --forward-to localhost:3000/webhooks/stripe`
4. Copy the webhook signing secret (starts with `whsec_...`)
5. Add to .env: `STRIPE_WEBHOOK_SECRET=whsec_...`

#### Production:
1. In Stripe Dashboard, go to **Developers** → **Webhooks**
2. Click **Add endpoint**
3. Enter your webhook URL: `https://your-app.fly.dev/webhooks/stripe`
4. Select events to listen to:
   - `checkout.session.completed`
   - `customer.subscription.updated`
   - `customer.subscription.deleted`
   - `invoice.payment_succeeded`
   - `invoice.payment_failed`
5. Click **Add endpoint**
6. Copy the **Signing secret** (starts with `whsec_...`)
7. Add to Fly.io: `fly secrets set STRIPE_WEBHOOK_SECRET=whsec_...`

### 6. Enable Customer Portal (Optional but Recommended)

The customer portal allows users to manage their subscriptions.

1. In Stripe Dashboard, go to **Settings** → **Billing** → **Customer portal**
2. Click **Activate**
3. Configure:
   - Allow customers to **update payment method**
   - Allow customers to **cancel subscription**
   - Allow customers to **view invoices**
4. Save settings

### 7. Test the Integration

1. Start your development server: `bin/dev`
2. Visit: http://localhost:3000/pricing
3. Click "Upgrade to Pro"
4. Use Stripe's test card: `4242 4242 4242 4242`
   - Any future expiry date
   - Any 3-digit CVC
   - Any ZIP code
5. Complete the checkout
6. Verify you're redirected to the success page
7. Check that your user account is upgraded to Pro

### 8. Deploy to Production

```bash
git add .
git commit -m "Add Stripe subscription functionality"
git push
fly deploy
```

## Testing Webhooks Locally

To test webhooks during development:

```bash
# Terminal 1: Start your Rails server
bin/dev

# Terminal 2: Forward Stripe webhooks
stripe listen --forward-to localhost:3000/webhooks/stripe
```

## Subscription Features

### Free Tier
- Up to 5 backlog tasks
- Daily task management
- Brain dump feature
- Pomodoro timer
- No calendar view
- No sprite rewards

### Pro Tier ($5/month)
- Unlimited backlog tasks
- All free features
- Calendar view
- Sprite rewards & gamification
- Priority support
- All future features

## Subscription Cancellation Flow

The app implements a user-friendly cancellation flow:

1. **Cancel Request**: When a user cancels their subscription, it's scheduled to end at the current billing period (not immediately)
2. **Grace Period**: User retains Pro access until the end of their paid period
3. **Status Updates**: Subscription status changes to "cancelling" during grace period
4. **Reactivation**: Users can reactivate their subscription any time before period end
5. **Automatic Downgrade**: At period end, user is automatically downgraded to free tier via webhook

### Subscription States
- `active`: Subscription is active and renewing
- `cancelling`: Subscription cancelled but still in paid period (grace period)
- `cancelled`: Subscription ended, user downgraded to free
- `past_due`: Payment failed, subscription at risk
- `inactive`: No subscription

### Database Fields
- `subscription_tier`: Current tier (free/pro)
- `subscription_status`: Current status (active/cancelling/cancelled/etc)
- `subscription_period_end`: DateTime when current period ends
- `stripe_subscription_id`: Stripe subscription ID
- `stripe_customer_id`: Stripe customer ID

### Key Methods
- `user.effective_subscription_tier`: Returns actual tier considering grace period
- `user.pro?`: Returns true if user has Pro access (including grace period)
- `user.subscription_grace_period?`: Returns true if subscription is cancelling but period hasn't ended

## URLs

- Pricing page: `/pricing`
- Upgrade page: `/subscriptions/new`
- Success page: `/subscriptions/success`
- Manage subscription: `/subscriptions/manage`
- Customer portal: `/subscriptions/portal`
- Cancel subscription: POST to `/subscriptions/cancel`
- Reactivate subscription: POST to `/subscriptions/reactivate`

## Common Issues

### "No such price" error
- Make sure `STRIPE_PRO_PRICE_ID` is set correctly
- Verify the price ID in your Stripe Dashboard

### Webhooks not working
- Check that `STRIPE_WEBHOOK_SECRET` is set
- Verify webhook endpoint URL is correct
- Check Stripe CLI is running (for development)
- Check webhook events are configured in Stripe Dashboard (for production)

### Subscription not activating
- Check the webhooks are being received
- Check Rails logs for errors
- Verify webhook secret is correct

## Support

For Stripe-specific issues, refer to:
- [Stripe Documentation](https://stripe.com/docs)
- [Stripe Support](https://support.stripe.com)
