class FeedbackMailer < ApplicationMailer
  def new_feedback(feedback)
    @feedback = feedback
    @user = feedback.user
    
    mail(
      to: "jb@wdpro.dev",
      subject: "[PlanMyDay Feedback] #{feedback.feedback_type.humanize}: #{feedback.subject}",
      from: "noreply@wdpro.dev",
      reply_to: @user.email_address
    )
  end
end
