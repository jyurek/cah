require 'spec_helper'

describe 'Games' do
  context 'POST to /games' do
    before do
      Game.white_card_path = "spec/fixtures/cards"
      Game.black_card_path = "spec/fixtures/black_cards"
      SecureRandom.stubs(:uuid).returns("1234-56-78")

      post '/games'

      @document = MultiJson.load(last_response.body)
    end

    it 'succeeds' do
      last_response.status.should == 200
    end

    it 'returns the game code' do
      @document['code'].should eq "aaaaa"
    end

    it 'returns me as a player with a hand of cards' do
      @document['players']['1234-56-78'].should eq (['Card']*10)
    end

    it 'name me the czar' do
      @document['play_order'].should eq ['1234-56-78']
    end

    it 'picks a black card' do
      @document['current_black_card'].should eq "Black Card"
    end

    it 'prints' do
      p @document
    end
  end

  context 'POST to /games/:code/player' do
    before do
      @game = Game.new
      @game.white_cards = Deck.new(["Card"] * 10)
      @game.black_cards = Deck.new(["Black"] * 10)
      @game.add_player("1234-56-78")

      SecureRandom.stubs(:uuid).returns("abcd-ef-gh")
      post '/games/aaaaa/player'

      @document = MultiJson.load(last_response.body)
    end

    it 'succeeds' do
      last_response.status.should == 200
    end

    it 'returns the new player\'s cards' do
      @document.should eq ['Card']*10
    end

    it 'prints' do
      p @document
    end
  end

  context 'GET to /games/:code' do
    before do
      Game.white_card_path = "spec/fixtures/cards"
      Game.black_card_path = "spec/fixtures/black_cards"
      @game = Game.new
      @game.add_player("1234-56-78")

      SecureRandom.stubs(:uuid).returns("abcd-ef-gh")
      post '/games/aaaaa/player'
      get '/games/aaaaa'

      @document = MultiJson.load(last_response.body)
    end

    it 'succeeds' do
      last_response.status.should == 200
    end

    it 'returns the new player\'s cards' do
      @document['players']['abcd-ef-gh'].should eq ['Card']*10
    end

    it 'still have player one as the czar' do
      @document['play_order'].should eq ['1234-56-78', 'abcd-ef-gh']
    end

    it 'prints' do
      p @document
    end
  end
end
