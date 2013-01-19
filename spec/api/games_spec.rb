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
  end

  context 'POST to /games/:code/answer' do
    it 'stores the answers in the game' do
      @game = Game.new
      @game.players['abcd-ef-gh'] = ['A Card', 'Another Card']
      @game.save
      SecureRandom.stubs(:uuid).returns("abcd-ef-gh")

      post '/games/aaaaa/answer', :card_names => "A Card"

      @document = MultiJson.load(last_response.body)
      @document['answers']['abcd-ef-gh'].should eq ['A Card']
      @document['players']['abcd-ef-gh'].should eq ['Another Card']
    end

    it 'complains when you play a card you do not have' do
      @game = Game.new
      @game.players['abcd-ef-gh'] = ['A Card', 'Another Card']
      SecureRandom.stubs(:uuid).returns("abcd-ef-gh")

      post '/games/aaaaa/answer', :card_names => "The winning card"

      p last_response
      last_response.status.should eq 406
    end
  end
end
