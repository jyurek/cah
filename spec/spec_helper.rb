require 'bundler'
Bundler.require :default, :test
require 'capybara/dsl'
require 'capybara/rspec'
require './cah_game'

require './spec/helpers/not_so_random_number_generator'

Capybara.app = CahGame.new
Capybara.default_driver = :rack_test
Capybara.javascript_driver = :webkit

Code.rng = NotSoRandomNumberGenerator.new(15596434)

RSpec.configure do |config|
  config.include Rack::Test::Methods

  def app
    CahGame.new
  end

  config.include ShowMeTheCookies
  config.mock_framework = :mocha
end
