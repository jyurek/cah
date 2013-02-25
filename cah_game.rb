require 'rubygems'
require 'bundler'
require 'securerandom'
Bundler.require

Dir.glob("./app/models/*") do |file|
  require file
end

class CardsNotInHandError < StandardError
end

class CahGame < Sinatra::Base
  helpers Sinatra::Cookies
  register Sinatra::JstPages
  serve_jst '/js/jst.js'

  set :views, File.dirname(__FILE__) + '/templates'
  set :show_exceptions, false
  set :raise_errors, true

  before do
    current_player
  end

  get '/' do
    erb :home
  end

  post '/games' do
    game = Game.new
    player = game.add_player(current_player)
    game.start_new_round
    game.save
    status 201
    game.to_json
  end

  get '/games/:code' do |code|
    game = Game.find(code)
    game.to_json
  end

  post '/games/:code/player' do |code|
    game = Game.find(code)
    if game.is_playing?(current_player)
      status 409
    else
      player = game.add_player(current_player)
      game.deal_hand_to(player)
      game.save
      pusher.trigger(game.code.to_s, "cah:new_player", player.cards)
      status 201
      player.to_json
    end
  end

  get '/games/:code/player' do |code|
    player = Player.find(current_player_id)
    player.to_json
  end

  post '/games/:code/answer' do |code|
    game = Game.find(code)
    if game.player_has_answered?(current_player)
      status 409
    elsif ! game.player_has_cards?(current_player, params['card_names'])
      status 409
    else
      game.answer(current_player, params['card_names'])
      pusher.trigger(game.code.to_s, "cah:answer_submitted",
                     player: current_player, cards: Array(params['card_names']))
      game.save
      status 201
    end
  end

  post '/games/:code/winner' do |code|
    game = Game.find(code)
    player_id = params['player_id']
    if game.is_playing?(player_id)
      if game.is_czar?(current_player)
        winning_cards = game.hand_winner(player_id)
        game.start_new_round
        game.save
        pusher.trigger(code, "cah:winner_chosen", {player: player_id, cards: Array(winning_cards)})
        pusher.trigger(code, "cah:game_state", game.to_hash)
        status 201
      else
        status 403
      end
    else
      status 409
      game.play_order[1..-1].to_json
    end
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
