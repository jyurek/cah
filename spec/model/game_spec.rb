require 'spec_helper'

describe Game do
  it 'initialize no players and a new code' do
    game = Game.new
    game.players.should == []
    game.code.to_s.should == "aaaaa"
  end

  it 'can render itself to JSON' do
    game = Game.new
    game_json = game.to_json

    parsed_json = MultiJson.load(game_json)
    parsed_json['players'].should == []
    parsed_json['code'].should == "aaaaa"
  end
end
