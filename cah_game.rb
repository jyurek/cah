require 'rubygems'
require 'bundler'
require 'securerandom'
Bundler.require

require './app/models/code'
require './app/models/game'

class CahGame < Sinatra::Base
  helpers Sinatra::Cookies
  register Sinatra::JstPages
  serve_jst '/js/jst.js'

  set :views, File.dirname(__FILE__) + '/templates'

  get '/' do
    set_player_id_unless_set
    erb :home
  end

  post '/games' do
    game = Game.new
    game.players << current_player
    game.start

    game.to_json
  end

  def set_player_id_unless_set
    cookies['player_id'] ||= SecureRandom.uuid
  end
end
