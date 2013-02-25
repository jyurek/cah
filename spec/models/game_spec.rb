require 'spec_helper'

describe Game do
  it 'initialize one player and a new code' do
    game = Game.new
    game.code.to_s.should == "aaaaa"
    game.players.should eq Hash.new
    game.play_order.should be_empty
  end

  it 'uses the first player in play order as the czar' do
    game = Game.new
    player1 = game.add_player("12345")
    game.deal_hand_to(player1)
    player2 = game.add_player("asdf")
    game.deal_hand_to(player2)

    game.czar.should == game.players["12345"]
  end

  it 'can add players if we know the player_id' do
    game = Game.new
    game.players["12345"].should be_nil

    player = game.add_player("12345")

    player.should be_a Player
    game.players["12345"].should eq player
  end

  it 'cannot add the same player twice' do
    game = Game.new
    game.add_player("12345")
    game.add_player("12345")

    game.players.keys.length.should eq 1
    game.play_order.length.should eq 1
  end

  it 'can dump itself to json' do
    game = Game.new
    game.current_black_card = "Card"
    game.players["12345"] = Player.new
    game.to_json.should eq '{"code":"aaaaa","current_black_card":"Card","players":{"12345":[]},"play_order":[],"answers":{},"score":{}}'
  end

  it 'gets the current black card from the black deck' do
    game = Game.new
    game.black_cards = Deck.load('spec/fixtures/one_card')
    game.current_black_card.should eq 'Card'
  end

  it 'deals cards to a player' do
    player = Player.new
    game = Game.new
    game.white_cards = Deck.load("spec/fixtures/ten_cards")

    game.deal_hand_to(player)

    player.cards.sort.should eq %w(0 1 2 3 4 5 6 7 8 9)
  end

  it 'moves cards from a players hand to the answers when they #answer' do
    game = Game.new
    player = Player.new
    game.players["abcd"] = player
    game.deal_hand_to(player)
    answer_cards = [player.cards.sample, player.cards.sample]

    game.answer("abcd", player.cards[0..2])

    answer_cards.each do |card|
      player.cards.should_not include(card)
      game.answers["abcd"].should include(card)
    end
  end

  it 'can dump and load itself' do
    game = Game.new
    player = Player.new
    game.deal_hand_to(player)
    game.players["12345"] = player
    game.save

    game2 = Game.find(game.code)

    game2.code.should eq game.code
    game2.play_order.should eq game.play_order
    game2.current_black_card.should eq game.current_black_card
    game2.players.should eq game.players
    game2.white_cards.should eq game.white_cards
    game2.black_cards.should eq game.black_cards
  end
end
