# Stripe Production Setup for Fly.io

This guide walks you through setting up Stripe payments in production on Fly.io.

## Prerequisites

- Stripe account with live mode enabled
- Fly.io app deployed
- Access to your Stripe Dashboard

## Step 1: Get Your Live Stripe Keys

1. Go to [Stripe Dashboard](https://dashboard.stripe.com)
2. **Toggle to "Live mode"** (switch in top right - should say "Viewing live data")
3. Navigate to **Developers → API keys**
4. Copy your **Publishable key** (starts with `pk_live_...`)
5. Click **"Reveal live key"** and copy your **Secret key** (starts with `sk_live_...`)

⚠️ **Important**: Make sure you're in **Live mode**, not Test mode!

## Step 2: Create Your Production Price

1. While in **Live mode**, go to **Products** in the left sidebar
2. Find or create "PlanMyDay Pro" product:
   - Click **"Add product"** if creating new
   - **Name**: PlanMyDay Pro
   - **Description**: Access to calendar, sprites, and unlimited backlog tasks
3. Add pricing:
   - **Pricing model**: Standard pricing
   - **Price**: $5.00 USD
   - **Billing period**: Monthly
4. Click **"Add product"** or **"Save product"**
5. Copy the **Price ID** (starts with `price_...`)
   - You can find this in the product details under the price section

## Step 3: Set Environment Variables on Fly.io

Run these commands in your terminal to set your Stripe secrets on Fly.io:

```bash
# Set Stripe publishable key (replace with your actual live key)
fly secrets set STRIPE_PUBLISHABLE_KEY=pk_live_YOUR_ACTUAL_PUBLISHABLE_KEY

# Set Stripe secret key (replace with your actual live key)
fly secrets set STRIPE_SECRET_KEY=sk_live_YOUR_ACTUAL_SECRET_KEY

# Set price ID (replace with your actual price ID)
fly secrets set STRIPE_PRO_PRICE_ID=price_YOUR_ACTUAL_PRICE_ID
```

**Example** (don't use these - use your own!):
```bash
fly secrets set STRIPE_PUBLISHABLE_KEY=pk_live_51AbCdEf...
fly secrets set STRIPE_SECRET_KEY=sk_live_51AbCdEf...
fly secrets set STRIPE_PRO_PRICE_ID=price_1AbCdEf...
```

⏳ **Note**: Setting secrets will trigger an automatic deployment. Wait for it to complete before continuing.

## Step 4: Set Up Webhook Endpoint

This is critical for subscriptions to work properly!

### Create the Webhook Destination

1. In Stripe Dashboard (**Live mode**), go to **Developers → Webhooks**
2. Click **"Add Destination"** button (the primary button on the page)

### Configure the Endpoint

3. **Endpoint URL**: Enter your production webhook URL
   ```
   https://planmyday-app.fly.dev/webhooks/stripe
   ```

4. **Description** (optional): "PlanMyDay Production Webhooks"

5. **Events to send**: Click **"Select events"**

   Select these **5 events** (use the search to find them quickly):
   - ✅ `checkout.session.completed` - When a customer completes checkout
   - ✅ `customer.subscription.updated` - When subscription changes (including cancellation)
   - ✅ `customer.subscription.deleted` - When subscription ends (critical for grace period!)
   - ✅ `invoice.payment_succeeded` - When monthly payment succeeds
   - ✅ `invoice.payment_failed` - When payment fails

6. Click **"Add events"**

7. Click **"Add destination"**

### Get the Webhook Signing Secret

8. You'll be taken to the webhook endpoint details page
9. Find the **"Signing secret"** section
10. Click **"Reveal"** or the eye icon
11. Copy the signing secret (starts with `whsec_...`)

### Set the Webhook Secret on Fly.io

12. In your terminal, run:
```bash
fly secrets set STRIPE_WEBHOOK_SECRET=whsec_YOUR_ACTUAL_WEBHOOK_SECRET
```

Replace `whsec_YOUR_ACTUAL_WEBHOOK_SECRET` with the signing secret you just copied.

## Step 5: Verify All Secrets Are Set

Check that all 4 Stripe secrets are configured:

```bash
fly secrets list
```

You should see:
- `STRIPE_PUBLISHABLE_KEY`
- `STRIPE_SECRET_KEY`
- `STRIPE_PRO_PRICE_ID`
- `STRIPE_WEBHOOK_SECRET`

(Note: The actual values will be hidden for security)

## Step 6: Enable Customer Portal (Recommended)

The Customer Portal allows users to manage their subscriptions directly through Stripe.

1. In Stripe Dashboard (**Live mode**), go to **Settings → Billing → Customer portal**
2. If not already activated, click **"Activate"**
3. Configure portal settings:
   - ✅ **Payment methods**: Allow customers to update payment methods
   - ✅ **Subscriptions**: Allow customers to cancel subscriptions
   - ✅ **Invoices**: Allow customers to view invoice history
4. Under **Cancellation options**:
   - Select: **"At the end of the billing period"** (matches our grace period behavior)
5. Click **"Save changes"**

## Step 7: Test Your Production Setup

### Test the Webhook Connection

1. In Stripe Dashboard, go to **Developers → Webhooks**
2. Click on your endpoint
3. Click the **"Send test webhook"** button
4. Select `checkout.session.completed` and click **"Send test webhook"**
5. Check the **Response** section - you should see a **200 OK** response
6. Check your Fly.io logs to confirm it was received:
   ```bash
   fly logs
   ```

### Test a Real Subscription

⚠️ **Warning**: This will charge a real credit card $5.00!

1. Visit your production site: `https://planmyday-app.fly.dev`
2. Sign up for a new account or log in
3. Go to `/pricing`
4. Click **"Upgrade to Pro"**
5. Complete checkout with a **real credit card**
6. Verify you're redirected to the success page
7. Check your account is upgraded to Pro
8. Go to `/subscriptions/manage` to verify subscription is active

### Test the Cancellation Flow

1. On the manage subscription page, click **"Cancel Subscription"**
2. You should see the cancellation feedback page
3. Fill out the feedback form and confirm cancellation
4. Verify you see the **"CANCELLING"** status
5. Verify you can still access Pro features
6. Check the grace period date is correct

### Verify Webhook Events

1. In Stripe Dashboard, go to **Developers → Webhooks**
2. Click on your endpoint
3. You should see recent webhook events with **✓ Succeeded** status
4. Common events after subscription:
   - `checkout.session.completed`
   - `customer.subscription.created`
   - `invoice.payment_succeeded`

## Quick Setup Commands (All at Once)

If you have all your keys ready, you can set everything at once:

```bash
fly secrets set \
  STRIPE_PUBLISHABLE_KEY=pk_live_YOUR_KEY \
  STRIPE_SECRET_KEY=sk_live_YOUR_SECRET \
  STRIPE_PRO_PRICE_ID=price_YOUR_PRICE_ID \
  STRIPE_WEBHOOK_SECRET=whsec_YOUR_WEBHOOK_SECRET
```

## Troubleshooting

### Webhook Events Not Being Received

**Symptoms**: Subscriptions create in Stripe but users aren't upgraded in your app

**Solutions**:
1. Check webhook URL is correct (must be `https://` not `http://`)
2. Verify all 5 events are selected in Stripe webhook settings
3. Check webhook signing secret is correct: `fly secrets list`
4. Look at Stripe webhook logs: **Developers → Webhooks → [Your endpoint] → View logs**
5. Check Fly.io app logs: `fly logs`
6. Test webhook: **Send test webhook** in Stripe Dashboard

### "No such price" Error

**Symptoms**: Error when clicking "Upgrade to Pro"

**Solutions**:
1. Verify you're using the **live mode** price ID, not test mode
2. Check the price ID in Stripe: **Products → [Your product] → Copy price ID**
3. Verify price ID is set: `fly secrets list`
4. Make sure price ID starts with `price_` not `prod_`

### Subscription Created But Not Activated

**Symptoms**: Payment succeeds but user stays on free tier

**Solutions**:
1. Check webhook is receiving `checkout.session.completed` event
2. Verify webhook secret is correct
3. Check Fly.io logs for errors: `fly logs`
4. Ensure app is using correct Stripe keys: `fly secrets list`

### Mixed Test/Live Mode Keys

**Symptoms**: Strange errors about customers not found

**Solutions**:
1. Make sure ALL keys are from live mode:
   - Publishable key: `pk_live_...` (not `pk_test_...`)
   - Secret key: `sk_live_...` (not `sk_test_...`)
   - Price ID: from live mode product
   - Webhook secret: from live mode webhook
2. Never mix test and live keys!

### Webhook Signature Verification Failed

**Symptoms**: Webhook events show "Signature verification failed" in logs

**Solutions**:
1. Regenerate webhook signing secret in Stripe Dashboard
2. Update the secret on Fly.io: `fly secrets set STRIPE_WEBHOOK_SECRET=whsec_...`
3. Make sure you copied the entire secret including `whsec_` prefix

## Security Best Practices

✅ **DO**:
- Use live keys only in production
- Keep webhook signing secret private
- Use HTTPS for webhook endpoint (Fly.io does this automatically)
- Verify webhook signatures (our app does this automatically)
- Monitor webhook event logs regularly

❌ **DON'T**:
- Commit Stripe keys to git
- Share your secret key
- Use test keys in production
- Disable webhook signature verification
- Ignore failed webhook events

## Monitoring Your Stripe Integration

### Check Webhook Health
1. Go to **Developers → Webhooks** in Stripe Dashboard
2. Click on your endpoint
3. Look for green checkmarks (✓ Succeeded)
4. Failed events will show in red - investigate these!

### View Customer Activity
1. Go to **Customers** in Stripe Dashboard
2. You'll see all your paying customers
3. Click on a customer to see:
   - Subscription status
   - Payment history
   - Upcoming invoices

### Monitor Failed Payments
1. Go to **Payments** in Stripe Dashboard
2. Filter by **"Failed"** status
3. Follow up with customers about failed payments

## Support

- **Stripe Documentation**: https://stripe.com/docs
- **Stripe Support**: https://support.stripe.com
- **Fly.io Documentation**: https://fly.io/docs
- **Check logs**: `fly logs` or in Fly.io dashboard

## Checklist

Use this checklist to ensure everything is set up correctly:

- [ ] Switched Stripe Dashboard to **Live mode**
- [ ] Copied live publishable key (`pk_live_...`)
- [ ] Copied live secret key (`sk_live_...`)
- [ ] Created PlanMyDay Pro product in live mode
- [ ] Copied price ID (`price_...`)
- [ ] Set `STRIPE_PUBLISHABLE_KEY` on Fly.io
- [ ] Set `STRIPE_SECRET_KEY` on Fly.io
- [ ] Set `STRIPE_PRO_PRICE_ID` on Fly.io
- [ ] Created webhook endpoint with production URL
- [ ] Selected all 5 required events
- [ ] Copied webhook signing secret (`whsec_...`)
- [ ] Set `STRIPE_WEBHOOK_SECRET` on Fly.io
- [ ] Verified all secrets with `fly secrets list`
- [ ] Enabled Stripe Customer Portal
- [ ] Tested webhook with "Send test webhook"
- [ ] Tested real subscription (optional - costs $5)
- [ ] Verified webhook events show as succeeded
- [ ] Tested cancellation flow
- [ ] Verified grace period works correctly

## Environment Variables Summary

Your production app needs these 4 Stripe environment variables:

| Variable | Example | Where to Get It |
|----------|---------|-----------------|
| `STRIPE_PUBLISHABLE_KEY` | `pk_live_51AbC...` | Stripe Dashboard → Developers → API keys |
| `STRIPE_SECRET_KEY` | `sk_live_51AbC...` | Stripe Dashboard → Developers → API keys (Reveal) |
| `STRIPE_PRO_PRICE_ID` | `price_1AbCdEf...` | Stripe Dashboard → Products → [Your product] |
| `STRIPE_WEBHOOK_SECRET` | `whsec_AbCdEf...` | Stripe Dashboard → Developers → Webhooks → [Your endpoint] |

All of these are set using:
```bash
fly secrets set VARIABLE_NAME=value
```
