require 'spec_helper'

describe Game do
  it 'initialize no players and a new code' do
    game = Game.new
    game.players.should == []
    game.code.to_s.should == "aaaaa"
  end
end
