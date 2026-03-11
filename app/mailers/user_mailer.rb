class UserMailer < ApplicationMailer
  def welcome_email(user)
    @user = user

    mail(
      to: user.email_address,
      subject: "Welcome to PlanMyDay - Let's tackle your ADHD together! 🚀",
      from: "noreply@wdpro.dev"
    )
  end
end
