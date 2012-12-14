require 'rubygems'
require 'bundler'
require 'securerandom'
Bundler.require

Dir.glob("./app/models/*") do |file|
  require file
end

class CahGame < Sinatra::Base
  helpers Sinatra::Cookies
  register Sinatra::JstPages
  serve_jst '/js/jst.js'

  set :views, File.dirname(__FILE__) + '/templates'

  get '/' do
    current_player
    erb :home
  end

  post '/games' do
    game = Game.new(current_player)
    game.to_json
  end

  get '/games/:code/cards' do |code|
  end

  def current_player
    cookies.options[:httponly] = false
    cookies['player_id'] ||= SecureRandom.uuid
  end
end
