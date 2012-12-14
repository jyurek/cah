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
    game.save
    game.to_json
  end

  get '/games/:code' do |code|
    game = Game.find(code)
    game.players << current_player
    game.save
    pusher.trigger(code, 'cah:new_player', current_player)
    game.to_json
  end

  get '/games/:code/cards' do |code|
  end

  def current_player
    cookies.options[:httponly] = false
    cookies['player_id'] ||= SecureRandom.uuid
  end

  def pusher
    @pusher ||= Pusher::Client.new(
      app_id: '33564',
      key: '0174638fca8826a47603',
      secret: 'f974ef24c1af90fdd5d1',
      encrypted: true
    )
  end
end
