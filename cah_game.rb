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
    game = Game.new
    player = game.add_player(current_player)
    game.deal_hand_to(player)
    game.save
    game.to_json
  end

  get '/games/:code' do |code|
    game = Game.find(code)
    game.to_json
  end

  post '/games/:code/player' do |code|
    game = Game.find(code)
    player = game.add_player(current_player)
    game.deal_hand_to(player)
    game.save
    unless player.existing_player
      pusher.trigger(game.code.to_s, "cah:new_player", nil)
    end
    player.to_json
  end

  get '/games/:code/player' do |code|
    player = Player.find(current_player_id)
    player.to_json
  end

  post '/games/:code/answer' do |code|
    game = Game.find(code)
    game.answer(current_player, params['card_names'])
    pusher.trigger(game.code.to_s, "cah:answer_submitted",
                   player: current_player, cards: params['card_names'])
    game.save
    game.to_json
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
