require "uri"
require "capybara/rspec"
require "capybara/cuprite"

require_relative "support/stack"

Capybara.register_driver(:cuprite) do |app|
  Capybara::Cuprite::Driver.new(
    app,
    window_size: [ 1280, 800 ],
    browser_options: { "no-sandbox" => nil, "disable-dev-shm-usage" => nil },
    inspector: false,
    headless: true
  )
end

Capybara.default_driver = :cuprite
Capybara.javascript_driver = :cuprite
Capybara.app_host = Stack::FRONTEND_URL
Capybara.run_server = false
Capybara.default_max_wait_time = 10

RSpec.configure do |config|
  config.expect_with(:rspec) { |expectations| expectations.syntax = :expect }
  config.disable_monkey_patching!
  config.order = :defined

  config.before(:suite) { Stack.start }
  config.after(:suite)  { Stack.stop }
end
