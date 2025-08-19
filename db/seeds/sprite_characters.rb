# Sprite Characters Seed Data
# Each sprite has unique pixel art style and unlock conditions

sprites = [
  # Common Sprites (Easy to unlock)
  {
    name: "Starter Bunny",
    description: "A cute pixel bunny that's always ready to help you start your journey!",
    unlock_condition: "Complete your first task",
    unlock_value: 1,
    sprite_type: "tasks",
    css_class: "sprite-bunny",
    rarity: "common"
  },
  {
    name: "Happy Cat",
    description: "This cheerful cat loves productive days!",
    unlock_condition: "Complete 3 tasks in one day",
    unlock_value: 3,
    sprite_type: "daily",
    css_class: "sprite-cat",
    rarity: "common"
  },
  {
    name: "Busy Bee",
    description: "Always buzzing with energy and ready to work!",
    unlock_condition: "Earn 50 points",
    unlock_value: 50,
    sprite_type: "points",
    css_class: "sprite-bee",
    rarity: "common"
  },
  {
    name: "Morning Bird",
    description: "The early bird that catches the worm!",
    unlock_condition: "early_bird",
    unlock_value: 0,
    sprite_type: "special",
    css_class: "sprite-bird",
    rarity: "common"
  },
  
  # Uncommon Sprites
  {
    name: "Study Owl",
    description: "A wise owl that appears when you work late into the night.",
    unlock_condition: "night_owl",
    unlock_value: 0,
    sprite_type: "special",
    css_class: "sprite-owl",
    rarity: "uncommon"
  },
  {
    name: "Streak Fox",
    description: "A clever fox that rewards consistency!",
    unlock_condition: "Maintain a 3-day streak",
    unlock_value: 3,
    sprite_type: "streak",
    css_class: "sprite-fox",
    rarity: "uncommon"
  },
  {
    name: "Task Master Turtle",
    description: "Slow and steady wins the race!",
    unlock_condition: "Complete 10 total tasks",
    unlock_value: 10,
    sprite_type: "tasks",
    css_class: "sprite-turtle",
    rarity: "uncommon"
  },
  {
    name: "Weekend Warrior Wolf",
    description: "This wolf doesn't rest on weekends!",
    unlock_condition: "weekend_warrior",
    unlock_value: 0,
    sprite_type: "special",
    css_class: "sprite-wolf",
    rarity: "uncommon"
  },
  
  # Rare Sprites
  {
    name: "Golden Hamster",
    description: "A shiny hamster that loves collecting points!",
    unlock_condition: "Earn 200 points",
    unlock_value: 200,
    sprite_type: "points",
    css_class: "sprite-hamster",
    rarity: "rare"
  },
  {
    name: "Fire Dragon",
    description: "A fierce dragon that appears with hot streaks!",
    unlock_condition: "Maintain a 7-day streak",
    unlock_value: 7,
    sprite_type: "streak",
    css_class: "sprite-dragon",
    rarity: "rare"
  },
  {
    name: "Productivity Penguin",
    description: "This cool penguin slides through tasks effortlessly!",
    unlock_condition: "Complete 25 total tasks",
    unlock_value: 25,
    sprite_type: "tasks",
    css_class: "sprite-penguin",
    rarity: "rare"
  },
  {
    name: "Achievement Unicorn",
    description: "A magical unicorn that celebrates your achievements!",
    unlock_condition: "Unlock 5 achievements",
    unlock_value: 5,
    sprite_type: "achievement",
    css_class: "sprite-unicorn",
    rarity: "rare"
  },
  
  # Epic Sprites
  {
    name: "Lightning Cheetah",
    description: "The fastest sprite, earned by completing many tasks quickly!",
    unlock_condition: "Complete 5 tasks in one day",
    unlock_value: 5,
    sprite_type: "daily",
    css_class: "sprite-cheetah",
    rarity: "epic"
  },
  {
    name: "Crystal Phoenix",
    description: "Rises from the ashes of completed tasks!",
    unlock_condition: "Complete 50 total tasks",
    unlock_value: 50,
    sprite_type: "tasks",
    css_class: "sprite-phoenix",
    rarity: "epic"
  },
  {
    name: "Cosmic Whale",
    description: "A majestic whale swimming through the stars of productivity!",
    unlock_condition: "Earn 500 points",
    unlock_value: 500,
    sprite_type: "points",
    css_class: "sprite-whale",
    rarity: "epic"
  },
  {
    name: "Thunder Lion",
    description: "The king of productivity with a mighty roar!",
    unlock_condition: "Maintain a 14-day streak",
    unlock_value: 14,
    sprite_type: "streak",
    css_class: "sprite-lion",
    rarity: "epic"
  },
  
  # Legendary Sprites
  {
    name: "Rainbow Butterfly",
    description: "An extremely rare butterfly that appears after perfect weeks!",
    unlock_condition: "perfect_week",
    unlock_value: 0,
    sprite_type: "special",
    css_class: "sprite-butterfly",
    rarity: "legendary"
  },
  {
    name: "Galaxy Bear",
    description: "A cosmic bear containing the power of a thousand stars!",
    unlock_condition: "Complete 100 total tasks",
    unlock_value: 100,
    sprite_type: "tasks",
    css_class: "sprite-bear",
    rarity: "legendary"
  },
  {
    name: "Diamond Robot",
    description: "The ultimate productivity machine made of pure diamond!",
    unlock_condition: "Earn 1000 points",
    unlock_value: 1000,
    sprite_type: "points",
    css_class: "sprite-robot",
    rarity: "legendary"
  },
  {
    name: "Eternal Flame Spirit",
    description: "A mystical spirit that embodies eternal productivity!",
    unlock_condition: "Maintain a 30-day streak",
    unlock_value: 30,
    sprite_type: "streak",
    css_class: "sprite-spirit",
    rarity: "legendary"
  }
]

sprites.each do |sprite_data|
  SpriteCharacter.find_or_create_by!(name: sprite_data[:name]) do |sprite|
    sprite.description = sprite_data[:description]
    sprite.unlock_condition = sprite_data[:unlock_condition]
    sprite.unlock_value = sprite_data[:unlock_value]
    sprite.sprite_type = sprite_data[:sprite_type]
    sprite.css_class = sprite_data[:css_class]
    sprite.rarity = sprite_data[:rarity]
  end
end

puts "Created #{SpriteCharacter.count} sprite characters!"