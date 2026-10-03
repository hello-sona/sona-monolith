ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)

require "bundler/setup" # Set up gems listed in the Gemfile.

# The repo-root .env is shared with the frontend and the Compose stack. Load it
# here so DB_* and GOOGLE_CLIENT_ID are set before config/database.yml is read.
# Dotenv never overwrites variables already present in the real environment.
require "dotenv"
Dotenv.load(File.expand_path("../../.env", __dir__))

require "bootsnap/setup" # Speed up boot time by caching expensive operations.
