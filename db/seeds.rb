# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

10.times do |i|
  start_date = (rand(1..20)).days.from_now.to_date
  Reunion.create({
    name: "Reunion #{i}",
    description: "Description for #{i}",
    location: "Location for #{i}",
    start_date: start_date,
    end_date: start_date + rand(1..20),
    state: ['published', 'draft'].sample
  })
end