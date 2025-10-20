class SpritesController < ApplicationController
  before_action :require_pro_subscription

  def index
    @user = Current.session.user
    
    # Get all sprites
    @all_sprites = SpriteCharacter.all.by_rarity
    
    # Get user's unlocked sprites
    @unlocked_sprites = @user.sprite_characters
    @unlocked_sprite_ids = @unlocked_sprites.pluck(:id)
    
    # Group sprites by rarity for display
    @sprites_by_rarity = {
      legendary: @all_sprites.legendary,
      epic: @all_sprites.epic,
      rare: @all_sprites.rare,
      uncommon: @all_sprites.uncommon,
      common: @all_sprites.common
    }
    
    # Calculate collection stats
    total_sprites = @all_sprites.count
    @collection_stats = {
      total_unlocked: @unlocked_sprites.count,
      total_sprites: total_sprites,
      percentage: total_sprites.zero? ? 0 : (@unlocked_sprites.count.to_f / total_sprites * 100).round,
      legendary_count: @unlocked_sprites.legendary.count,
      epic_count: @unlocked_sprites.epic.count,
      rare_count: @unlocked_sprites.rare.count,
      uncommon_count: @unlocked_sprites.uncommon.count,
      common_count: @unlocked_sprites.common.count
    }
    
    # Get recently unlocked sprites
    @recent_unlocks = @user.user_sprites.recent.limit(5).includes(:sprite_character)
  end

  private

  def require_pro_subscription
    unless current_user&.can_access_sprites?
      redirect_to pricing_path, alert: "Sprite rewards are a Pro feature. Upgrade to unlock!"
    end
  end
end
