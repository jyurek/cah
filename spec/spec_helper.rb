require 'bundler'
Bundler.require :default, :test
require 'capybara/dsl'
require 'capybara/rspec'
require './cah_game'

Dir[File.expand_path(File.join(__FILE__, "..", "helpers", "*"))].each do |file|
  require file
end

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

Capybara.register_driver :webkit do |app|
  Capybara::Webkit::Driver.new(app, :stdout => nil)
end
