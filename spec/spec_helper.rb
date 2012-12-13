require 'bundler'
Bundler.require :default, :test
require 'capybara/dsl'
require 'capybara/rspec'
require './app'

Capybara.app = Sinatra::Application
