# EXAMPLE: How to use the ApiRateLimiter in your controllers
#
# This file shows how to protect your controllers from API abuse
# when you add OpenAI or other expensive API integrations

module ExampleApiUsage
  # Example 1: In BrainDumpsController when adding AI processing
  def process_with_ai
    # Check rate limit before making expensive API call
    remaining_calls = check_api_limit!('brain_dump_ai')
    
    # Make your OpenAI API call here
    # response = OpenAI::Client.new.completions(...)
    
    flash[:notice] = "Processing complete! You have #{remaining_calls} AI processes left today."
    redirect_to brain_dumps_path
  rescue ApiRateLimiter::RateLimitExceeded => e
    # This is handled automatically by the concern
    # User sees alert and is redirected back
  end
  
  # Example 2: Custom limit for a specific feature
  def generate_suggestions
    # Custom limit of 10 per day for this feature
    check_api_limit!('task_suggestions', custom_limit: 10)
    
    # Your AI logic here
  end
  
  # Example 3: Check remaining calls without incrementing
  def show_remaining_calls
    usage = ApiUsage.find_or_create_by(
      user: current_user,
      endpoint: 'openai',
      date: Date.current
    )
    
    daily_limit = ApiRateLimiter::DAILY_LIMITS['openai']
    remaining = daily_limit - usage.count
    
    render json: { remaining_calls: remaining, daily_limit: daily_limit }
  end
end

# To use in your controller:
#
# class BrainDumpsController < ApplicationController
#   include ApiRateLimiter
#   
#   def process_dump
#     check_api_limit!('brain_dump_ai')
#     # Your AI processing code here
#   end
# end