
User.create!(
	first_name: "admin",
	last_name: "user",
	email: "admin@example.com",
	password: "asdf",
	password_confirmation: "asdf",
	phone_number: "123456789",
	address_line1: Faker::Address.street_address,
	city: "Toronto",
	postal_code: Faker::Address.zip_code
)

puts "Creating Users"
puts "========================================================="

50.times do
	name = Faker::Name.name.split
	User.create!(
		first_name: name.first,
		last_name: name.last,
		email: Faker::Internet.email,
		password: "asdf",
		password_confirmation: "asdf",
		phone_number: Faker::PhoneNumber.phone_number,
		address_line1: Faker::Address.street_address,
	    city: Faker::Address.city,
	    postal_code: Faker::Address.zip_code
	)
end

puts "Creating Items"
puts "========================================================="
150.times do

  	Item.create!(
	    title: Faker::Commerce.product_name,
	    description: Faker::Lorem.sentence,
	    deposit: Faker::Commerce.price,
	    rent2buy: true,
	    tags:Faker::Commerce.department
    )
end

puts "Creating Reviews"
puts "========================================================="
150.times do
	reviewer_user = User.all.sample
	r = Review.create!(
		comment: Faker::Lorem.paragraph,
		user_id: User.all.sample.id,
		item_id: Item.all.sample.id
    )
    puts "Made review for #{r.item.title} by #{r.user.full_name}"
end


puts "Creating Ratings"
puts "========================================================="
150.times do
	r = Rating.create!(
		user_id: User.all.sample.id,
		item_id: Item.all.sample.id,
		score: [*0..4].sample
	)
	puts "Made rating of #{r.score} for #{r.item.title}"
end

