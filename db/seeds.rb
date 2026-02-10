areas = [
  { name: "Kitchen", icon: "🍳", position: 1 },
  { name: "Bathroom", icon: "🚿", position: 2 },
  { name: "Bedroom", icon: "🛏️", position: 3 },
  { name: "Living Room", icon: "🛋️", position: 4 },
  { name: "Outdoor", icon: "🌳", position: 5 },
  { name: "Garage", icon: "🔧", position: 6 },
  { name: "Basement", icon: "⬇️", position: 7 },
  { name: "Attic", icon: "⬆️", position: 8 },
  { name: "Studio", icon: "🎨", position: 9 },
  { name: "Whole House", icon: "🏠", position: 10 }
]

areas.each do |attrs|
  Area.find_or_create_by!(name: attrs[:name]) do |area|
    area.icon = attrs[:icon]
    area.is_default = true
    area.position = attrs[:position]
  end
end

puts "Seeded #{Area.count} areas"
