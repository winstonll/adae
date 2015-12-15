
User.create!(
	name: "admin",
	email: "admin@example.com",
	password: "asdf1234",
	password_confirmation: "asdf1234",
	
)

puts "Creating Users"
puts "========================================================="

25.times do
	name = Faker::Name.name.split
	User.create!(
		name: name.first,
		surname: name.last,
		email: Faker::Internet.email,
		password: "asdf1234",
		password_confirmation: "asdf1234",
		)
end

puts "Creating Items"
puts "========================================================="
	
user = User.all
user.each do |user|
	 Item.create!(
	    title: Faker::Commerce.product_name,
	    description: Faker::Lorem.sentence,
	    deposit: Faker::Commerce.price,
	    tags: Faker::Commerce.department,
	    postal_code: Faker::Address.postcode,
	    user_id: user.id
    )
end

puts "Creating Prices"
puts "========================================================="

item = Item.all

item.each do |item|
	Price.create!(
		timeframe: ["Hour", "Day", "Week"].sample,
		amount: Faker::Commerce.price,
		item_id: item.id
		)
end

puts "Creating Reviews"
puts "========================================================="
25.times do
	reviewer_user = User.all.sample
	r = Review.create!(
		comment: Faker::Lorem.paragraph,
		user_id: User.all.sample.id,
		item_id: Item.all.sample.id
    )
    puts "Made review for #{r.item.title} by #{r.user.name}"
end


puts "Creating Ratings"
puts "========================================================="
25.times do
	r = Rating.create!(
		user_id: User.all.sample.id,
		item_id: Item.all.sample.id,
		score: [*0..4].sample
	)
	puts "Made rating of #{r.score} for #{r.item.title}"
end

