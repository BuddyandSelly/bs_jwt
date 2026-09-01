# frozen_string_literal: true

require 'bundler/setup'
require 'simplecov'

SimpleCov.start do
  enable_coverage :branch
  primary_coverage :branch

  # Everything the gem ships has to be covered, whether it was loaded or not.
  cover '{lib}/**/*.{rb,rake}'
  # Loaded by the gemspec, and therefore by bundler, before coverage starts.
  skip 'lib/bs_jwt/version.rb'

  minimum_coverage line: 100, branch: 100
end

require 'bs_jwt'
require 'faraday'
require 'byebug'
require 'webmock/rspec'
require 'rspec'
require 'factory_bot'
require 'bs_jwt/factories'

Dir[File.join(__dir__, 'support', '**', '*.rb')].each { |file| require file }

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.mock_with :rspec do |mocks|
    mocks.syntax = :expect
    mocks.verify_partial_doubles = true
  end

  config.order = :random

  config.include FactoryBot::Syntax::Methods
  config.include JwksHelpers
  config.include RakeHelpers

  config.before(:suite) do
    FactoryBot.find_definitions
  end

  # `BsJwt` keeps global configuration and memoizes the fetched JWKS, so every
  # example has to start from the state the suite was loaded with.
  config.around do |example|
    BsJwtState.reset!
    example.run
    BsJwtState.reset!
  end
end
