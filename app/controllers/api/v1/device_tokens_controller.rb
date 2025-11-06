module Api
  module V1
    class DeviceTokensController < ApplicationController
      before_action :require_authentication

      # POST /api/v1/device_tokens
      # Register a device token for push notifications
      def create
        device_token = DeviceToken.register(
          current_user,
          params[:token],
          params[:platform]
        )

        if device_token.persisted?
          render json: {
            success: true,
            message: "Device token registered successfully"
          }, status: :created
        else
          render json: {
            success: false,
            errors: device_token.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/device_tokens/:id
      # Deactivate a device token
      def destroy
        device_token = current_user.device_tokens.find(params[:id])
        device_token.deactivate!

        render json: {
          success: true,
          message: "Device token deactivated"
        }, status: :ok
      end
    end
  end
end
