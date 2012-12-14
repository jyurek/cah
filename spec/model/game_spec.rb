require 'spec_helper'

describe Game do
  it 'initialize no players and a new code' do
    game = Game.new("12345")
    game.players.should == ["12345"]
    game.code.to_s.should == "aaaaa"
  end

  it 'can render itself to JSON' do
    game = Game.new("12345")
    game_json = game.to_json

    parsed_json = MultiJson.load(game_json)
    parsed_json['players'].should == ["12345"]
    parsed_json['code'].should == "aaaaa"
  end
end
