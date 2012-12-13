require 'bundler'
Bundler.require :default, :test
require 'capybara/dsl'
require 'capybara/rspec'
require './cah_game'

Capybara.app = CahGame.new
Capybara.default_driver = :webkit
