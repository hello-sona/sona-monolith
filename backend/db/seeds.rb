# Local development only. Creates or resets the admin test account.
# Run with: bin/rails db:seed
TEST_USER = {
  email: "admin@example.com",
  display_name: "admin",
  password: "password!123"
}.freeze

user = User.find_or_initialize_by(email: TEST_USER[:email])
created = user.new_record?

user.display_name = TEST_USER[:display_name]
user.password = TEST_USER[:password]
user.admin = true
user.active = true
user.save!

puts "#{created ? 'Created' : 'Updated'} test user #{user.email}."
puts "Sign in with admin or #{user.email} / #{TEST_USER[:password]}."
