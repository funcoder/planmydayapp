class RegistrationsController < ApplicationController
  allow_unauthenticated_access
  
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    
    if @user.save
      # Send notification email to admin
      AdminNotificationMailer.new_user_signup(@user).deliver_later
      
      # Send welcome email to new user
      UserMailer.welcome_email(@user).deliver_later
      
      start_new_session_for(@user)
      redirect_to dashboard_path, notice: "Welcome to PlanMyDay!"
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  private
  
  def user_params
    params.require(:user).permit(:email_address, :password, :password_confirmation, :first_name, :last_name)
  end
end