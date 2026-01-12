class AnnouncementsController < ApplicationController
  def index
    @announcements = FeatureAnnouncement.for_user(current_user)
    @unseen_ids = current_user.unseen_announcements.pluck(:id)
  end

  def mark_seen
    announcements = FeatureAnnouncement.where(id: params[:ids])
    current_user.mark_announcements_as_seen(announcements)

    respond_to do |format|
      format.html { redirect_back fallback_location: dashboard_path }
      format.json { render json: { success: true, unseen_count: current_user.unseen_announcements_count } }
    end
  end

  def mark_all_seen
    current_user.mark_announcements_as_seen(current_user.unseen_announcements)

    respond_to do |format|
      format.html { redirect_back fallback_location: dashboard_path }
      format.json { render json: { success: true, unseen_count: 0 } }
    end
  end
end
