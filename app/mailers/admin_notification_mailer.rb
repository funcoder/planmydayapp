class AdminNotificationMailer < ApplicationMailer
  def new_user_signup(user)
    @user = user
    @signup_time = user.created_at.strftime("%B %d, %Y at %I:%M %p %Z")
    
    mail(
      to: "jb@wdpro.dev",
      subject: "[PlanMyDay] New User Signup: #{user.first_name} #{user.last_name}",
      from: "noreply@wdpro.dev"
    )
  end
end
