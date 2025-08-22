# Gmail/Google Workspace SMTP Configuration
# For production, use Rails credentials to store sensitive information

if Rails.env.development?
  ActionMailer::Base.delivery_method = :smtp
  ActionMailer::Base.smtp_settings = {
    address:              'smtp.gmail.com',
    port:                 587,
    domain:               'wdpro.dev',
    user_name:            ENV['GMAIL_USERNAME'] || 'your-email@wdpro.dev',
    password:             ENV['GMAIL_APP_PASSWORD'], # Use App Password, not regular password
    authentication:       'plain',
    enable_starttls_auto: true,
    open_timeout:         5,
    read_timeout:         5
  }
  
  # For development testing, you can use letter_opener gem or log emails
  # Uncomment the line below to just log emails instead of sending them
  # ActionMailer::Base.delivery_method = :test
elsif Rails.env.production?
  ActionMailer::Base.delivery_method = :smtp
  ActionMailer::Base.smtp_settings = {
    address:              'smtp.gmail.com',
    port:                 587,
    domain:               'wdpro.dev',
    user_name:            ENV['GMAIL_USERNAME'],
    password:             ENV['GMAIL_APP_PASSWORD'],
    authentication:       'plain',
    enable_starttls_auto: true,
    open_timeout:         5,
    read_timeout:         5
  }
end