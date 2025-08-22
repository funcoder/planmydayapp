class FeedbacksController < ApplicationController
  def new
    @feedback = current_user.feedbacks.build
  end

  def create
    @feedback = current_user.feedbacks.build(feedback_params)
    
    if @feedback.save
      FeedbackMailer.new_feedback(@feedback).deliver_later
      redirect_to dashboard_path, notice: "Thank you for your feedback! We'll review it and get back to you soon."
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  def index
    @feedbacks = current_user.feedbacks.recent
  end
  
  private
  
  def feedback_params
    params.require(:feedback).permit(:feedback_type, :subject, :message)
  end
end
