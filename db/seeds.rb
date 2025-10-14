# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "Seeding Sprite Characters..."

# Common Sprites
SpriteCharacter.find_or_create_by!(name: "Bunny") do |sprite|
  sprite.css_class = "sprite-bunny"
  sprite.rarity = "common"
  sprite.sprite_type = "tasks"
  sprite.unlock_value = 1
  sprite.unlock_condition = "Complete your first task"
  sprite.description = "A friendly bunny to celebrate your first completed task!"
end

SpriteCharacter.find_or_create_by!(name: "Cat") do |sprite|
  sprite.css_class = "sprite-cat"
  sprite.rarity = "common"
  sprite.sprite_type = "tasks"
  sprite.unlock_value = 5
  sprite.unlock_condition = "Complete 5 tasks"
  sprite.description = "A curious cat that appears after completing 5 tasks"
end

SpriteCharacter.find_or_create_by!(name: "Bee") do |sprite|
  sprite.css_class = "sprite-bee"
  sprite.rarity = "common"
  sprite.sprite_type = "streak"
  sprite.unlock_value = 3
  sprite.unlock_condition = "Maintain a 3-day streak"
  sprite.description = "A busy bee for staying consistent!"
end

SpriteCharacter.find_or_create_by!(name: "Bird") do |sprite|
  sprite.css_class = "sprite-bird"
  sprite.rarity = "common"
  sprite.sprite_type = "points"
  sprite.unlock_value = 100
  sprite.unlock_condition = "Earn 100 points"
  sprite.description = "A cheerful bird celebrating your first 100 points"
end

# Uncommon Sprites
SpriteCharacter.find_or_create_by!(name: "Owl") do |sprite|
  sprite.css_class = "sprite-owl"
  sprite.rarity = "uncommon"
  sprite.sprite_type = "tasks"
  sprite.unlock_value = 15
  sprite.unlock_condition = "Complete 15 tasks"
  sprite.description = "A wise owl watching over your progress"
end

SpriteCharacter.find_or_create_by!(name: "Fox") do |sprite|
  sprite.css_class = "sprite-fox"
  sprite.rarity = "uncommon"
  sprite.sprite_type = "streak"
  sprite.unlock_value = 7
  sprite.unlock_condition = "Maintain a 7-day streak"
  sprite.description = "A clever fox for your weekly streak!"
end

SpriteCharacter.find_or_create_by!(name: "Turtle") do |sprite|
  sprite.css_class = "sprite-turtle"
  sprite.rarity = "uncommon"
  sprite.sprite_type = "points"
  sprite.unlock_value = 250
  sprite.unlock_condition = "Earn 250 points"
  sprite.description = "Slow and steady wins the race"
end

SpriteCharacter.find_or_create_by!(name: "Wolf") do |sprite|
  sprite.css_class = "sprite-wolf"
  sprite.rarity = "uncommon"
  sprite.sprite_type = "daily"
  sprite.unlock_value = 5
  sprite.unlock_condition = "Complete 5 tasks in one day"
  sprite.description = "A fierce wolf for power users"
end

# Rare Sprites
SpriteCharacter.find_or_create_by!(name: "Hamster") do |sprite|
  sprite.css_class = "sprite-hamster"
  sprite.rarity = "rare"
  sprite.sprite_type = "tasks"
  sprite.unlock_value = 30
  sprite.unlock_condition = "Complete 30 tasks"
  sprite.description = "A golden hamster for dedicated achievers"
end

SpriteCharacter.find_or_create_by!(name: "Dragon") do |sprite|
  sprite.css_class = "sprite-dragon"
  sprite.rarity = "rare"
  sprite.sprite_type = "streak"
  sprite.unlock_value = 14
  sprite.unlock_condition = "Maintain a 14-day streak"
  sprite.description = "A powerful dragon for two weeks of consistency"
end

SpriteCharacter.find_or_create_by!(name: "Penguin") do |sprite|
  sprite.css_class = "sprite-penguin"
  sprite.rarity = "rare"
  sprite.sprite_type = "points"
  sprite.unlock_value = 500
  sprite.unlock_condition = "Earn 500 points"
  sprite.description = "A dapper penguin celebrating your milestone"
end

SpriteCharacter.find_or_create_by!(name: "Unicorn") do |sprite|
  sprite.css_class = "sprite-unicorn"
  sprite.rarity = "rare"
  sprite.sprite_type = "special"
  sprite.unlock_value = 0
  sprite.unlock_condition = "perfect_week"
  sprite.description = "Complete 5+ tasks every day for 7 days"
end

# Epic Sprites
SpriteCharacter.find_or_create_by!(name: "Cheetah") do |sprite|
  sprite.css_class = "sprite-cheetah"
  sprite.rarity = "epic"
  sprite.sprite_type = "tasks"
  sprite.unlock_value = 50
  sprite.unlock_condition = "Complete 50 tasks"
  sprite.description = "The fastest sprite for speed demons"
end

SpriteCharacter.find_or_create_by!(name: "Phoenix") do |sprite|
  sprite.css_class = "sprite-phoenix"
  sprite.rarity = "epic"
  sprite.sprite_type = "streak"
  sprite.unlock_value = 30
  sprite.unlock_condition = "Maintain a 30-day streak"
  sprite.description = "Rise from the ashes with a month-long streak"
end

SpriteCharacter.find_or_create_by!(name: "Whale") do |sprite|
  sprite.css_class = "sprite-whale"
  sprite.rarity = "epic"
  sprite.sprite_type = "points"
  sprite.unlock_value = 1000
  sprite.unlock_condition = "Earn 1000 points"
  sprite.description = "A majestic whale for reaching 1000 points"
end

SpriteCharacter.find_or_create_by!(name: "Lion") do |sprite|
  sprite.css_class = "sprite-lion"
  sprite.rarity = "epic"
  sprite.sprite_type = "achievement"
  sprite.unlock_value = 10
  sprite.unlock_condition = "Earn 10 achievements"
  sprite.description = "King of the productivity jungle"
end

# Legendary Sprites
SpriteCharacter.find_or_create_by!(name: "Butterfly") do |sprite|
  sprite.css_class = "sprite-butterfly"
  sprite.rarity = "legendary"
  sprite.sprite_type = "tasks"
  sprite.unlock_value = 100
  sprite.unlock_condition = "Complete 100 tasks"
  sprite.description = "Transform into a productivity master"
end

SpriteCharacter.find_or_create_by!(name: "Cosmic Bear") do |sprite|
  sprite.css_class = "sprite-bear"
  sprite.rarity = "legendary"
  sprite.sprite_type = "streak"
  sprite.unlock_value = 60
  sprite.unlock_condition = "Maintain a 60-day streak"
  sprite.description = "A celestial guardian for 60 days of dedication"
end

SpriteCharacter.find_or_create_by!(name: "Robot") do |sprite|
  sprite.css_class = "sprite-robot"
  sprite.rarity = "legendary"
  sprite.sprite_type = "points"
  sprite.unlock_value = 2500
  sprite.unlock_condition = "Earn 2500 points"
  sprite.description = "Maximum efficiency achieved"
end

SpriteCharacter.find_or_create_by!(name: "Spirit") do |sprite|
  sprite.css_class = "sprite-spirit"
  sprite.rarity = "legendary"
  sprite.sprite_type = "special"
  sprite.unlock_value = 0
  sprite.unlock_condition = "weekend_warrior"
  sprite.description = "Complete tasks on both Saturday and Sunday"
end

puts "✓ Created #{SpriteCharacter.count} sprite characters"
