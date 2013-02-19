require 'spec_helper'

describe Player do
  it 'initializes empty' do
    player = Player.new
    player.cards.should be_empty
  end
end
