# Gmail/Google Workspace Email Setup for PlanMyDay

## Setting Up Email Sending

### 1. Create a Google App Password

Since you're using Google Workspace (wdpro.dev), you need to create an App Password for email sending:

1. Go to https://myaccount.google.com/security
2. Enable 2-Step Verification if not already enabled
3. Under "2-Step Verification", scroll down to "App passwords"
4. Click on "App passwords"
5. Select "Mail" as the app
6. Select "Other" as the device and name it "PlanMyDay"
7. Click "Generate"
8. Copy the 16-character password (spaces don't matter)

### 2. Set Environment Variables

#### For Local Development:
Create a `.env` file in your project root:
```bash
GMAIL_USERNAME=your-email@wdpro.dev
GMAIL_APP_PASSWORD=your-16-char-app-password
```

Or export them in your terminal:
```bash
export GMAIL_USERNAME="your-email@wdpro.dev"
export GMAIL_APP_PASSWORD="xxxx xxxx xxxx xxxx"
```

#### For Production (Fly.io):
```bash
fly secrets set GMAIL_USERNAME="your-email@wdpro.dev"
fly secrets set GMAIL_APP_PASSWORD="xxxx xxxx xxxx xxxx"
```

### 3. Test Email Sending

After setting up, restart your Rails server and test password reset:
1. Go to http://localhost:3000/passwords/new
2. Enter your email
3. Check if email is sent

### 4. Alternative: Use Letter Opener for Development

If you want to test emails without actually sending them, add to Gemfile:
```ruby
group :development do
  gem 'letter_opener'
end
```

Then in `config/environments/development.rb`:
```ruby
config.action_mailer.delivery_method = :letter_opener
config.action_mailer.perform_deliveries = true
```

This will open emails in your browser instead of sending them.

## Current Configuration

- **SMTP Server**: smtp.gmail.com
- **Port**: 587
- **Domain**: wdpro.dev
- **From Address**: noreply@wdpro.dev
- **Authentication**: Plain with App Password

## Troubleshooting

1. **Authentication Error**: Make sure you're using an App Password, not your regular password
2. **Connection Timeout**: Check firewall settings
3. **Email Not Sending**: Check Rails logs for detailed error messages
4. **"Less Secure Apps"**: Not needed with App Passwords

## Security Notes

- Never commit your App Password to git
- Use environment variables or Rails credentials
- Rotate App Passwords periodically
- Consider using a dedicated email service (SendGrid, Postmark) for production