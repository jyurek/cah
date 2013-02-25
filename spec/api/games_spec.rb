require 'spec_helper'

describe 'Games' do
  let(:pusher){ FakePusher.new }
  before do
    Game.white_card_path = "spec/fixtures/cards"
    Game.black_card_path = "spec/fixtures/black_cards"
    Pusher::Client.stubs(:new).returns(pusher)
    SecureRandom.stubs(:uuid).returns("abcd-ef-gh")
  end

  context 'GET to /' do
    before do
      get '/'
    end

    it 'succeeds' do
      last_response.status.should == 200
    end

    it 'sets a cookie for a new user' do
      last_response.headers['Set-Cookie'].should include("player_id=abcd-ef-gh")
    end
  end

  context 'POST to /games' do
    before do
      post '/games'
      @document = MultiJson.load(last_response.body)
    end

    it 'succeeds' do
      last_response.status.should == 201
    end

    it 'returns the game code' do
      @document['code'].should eq "aaaaa"
    end

    it 'returns me as a player with a hand of cards' do
      @document['players']['abcd-ef-gh'].should eq (['Card']*10)
    end

    it 'name me the czar' do
      @document['play_order'].should eq ['abcd-ef-gh']
    end

    it 'picks a black card' do
      @document['current_black_card'].should eq "Black Card"
    end
  end

  context 'POST to /games/:code/player' do
    before do
      @game = Game.new
      @game.add_player("1234-56-78")
      @game.save

      post '/games/aaaaa/player'

      @document = MultiJson.load(last_response.body)
    end

    it 'succeeds' do
      last_response.status.should == 201
    end

    it 'return the player in JSON' do
      @document.should eq (['Card']*10)
    end

    it 'triggers an event to tell other players about the new player' do
      pusher.events.first.should eq ['aaaaa', 'cah:new_player', @document]
    end
  end

  context 'POST to /games/:code/player when they are already in the game' do
    before do
      @game = Game.new
      @game.add_player("1234-56-78")
      @game.save

      post '/games/aaaaa/player'
      post '/games/aaaaa/player'

      @document = last_response.body
    end

    it 'returns a response of 409 (Conflict)' do
      last_response.status.should == 409
    end

    it 'return nothing' do
      @document.should be_empty
    end
  end

  context 'GET to /games/:code when two people are playing' do
    before do
      @game = Game.new
      player = @game.add_player("1234-56-78")
      @game.deal_hand_to(player)
      @game.save

      post '/games/aaaaa/player'
      get '/games/aaaaa'

      @document = MultiJson.load(last_response.body)
    end

    it 'succeeds' do
      last_response.status.should == 200
    end

    it 'returns both players\' cards' do
      @document['players']['abcd-ef-gh'].should eq ['Card']*10
      @document['players']['1234-56-78'].should eq ['Card']*10
    end

    it 'has no answers' do
      @document['answers'].should be_empty
    end

    it 'has no score' do
      @document['score'].should be_empty
    end

    it 'still has player one as the czar' do
      @document['play_order'].should eq ['1234-56-78', 'abcd-ef-gh']
    end
  end

  context 'POST to /games/:code/answer' do
    before do
      @game = Game.new
      @game.players['abcd-ef-gh'] = ['A Card', 'Another Card']
      @game.save

      post '/games/aaaaa/answer', :card_names => "A Card"
    end

    it 'succeeds' do
      last_response.status.should eq 201
    end

    it 'sends no body' do
      last_response.body.should be_empty
    end

    it 'sends an event that an answer was given' do
      pusher.events.first.should eq ['aaaaa', 'cah:answer_submitted', {player: 'abcd-ef-gh', cards: ['A Card']}]
    end
  end

  context 'POST to /games/:code/answer when that player has answered' do
    before do
      @game = Game.new
      @game.players['abcd-ef-gh'] = ['A Card', 'Another Card']
      @game.save

      post '/games/aaaaa/answer', :card_names => "A Card"
      pusher.events.clear
      post '/games/aaaaa/answer', :card_names => "Another Card"
    end

    it 'does not succeed with a 409 (Conflict)' do
      last_response.status.should eq 409
    end

    it 'contains no body' do
      last_response.body.should be_empty
    end

    it 'sends no new events' do
      pusher.events.should be_empty
    end
  end

  context 'POST to /games/:code/answer with a card the player does not have' do
    before do
      @game = Game.new
      @game.players['abcd-ef-gh'] = ['A Card', 'Another Card']
      @game.save

      post '/games/aaaaa/answer', :card_names => "A NEW Card"
    end

    it 'does not succeed with a 409 (Conflict)' do
      last_response.status.should eq 409
    end

    it 'sends no body' do
      last_response.body.should be_empty
    end

    it 'sends no new events' do
      pusher.events.should be_empty
    end
  end

  context 'POST to /games/:code/winner when you are czar' do
    before do
      @game = Game.new
      @game.add_player("abcd-ef-gh")
      @game.add_player("1234-56-78")
      @game.answer("1234-56-78", ['A Card'])
      @game.save

      post '/games/aaaaa/winner', :player_id => "1234-56-78"
    end

    it 'succeeds' do
      last_response.status.should eq 201
    end

    it 'have no body' do
      last_response.body.should be_empty
    end

    it 'sends an event that a winner was picked' do
      pusher.events.first.should eq ['aaaaa', 'cah:winner_chosen', {player: '1234-56-78', cards: ['A Card']}]
    end

    it 'sends an event to refresh the game state' do
      expected_gamestate = {
        code: "aaaaa",
        play_order: ["1234-56-78", "abcd-ef-gh"],
        current_black_card: "Black Card",
        players: {
          "abcd-ef-gh"=> Player.new(["Card"] * 10),
          "1234-56-78"=> Player.new(["Card"] * 10)
        },
        play_order: ["1234-56-78", "abcd-ef-gh"],
        answers: {},
        score: {"1234-56-78"=>1}
      }
      pusher.events.last.should eq ['aaaaa', 'cah:game_state', expected_gamestate]
    end
  end

  context 'POST to /games/:code/winner when you are czar, but for an incorrect player' do
    before do
      @game = Game.new
      @game.add_player("abcd-ef-gh")
      @game.add_player("1234-56-78")
      @game.answer("1234-56-78", ['A Card'])
      @game.save

      post '/games/aaaaa/winner', :player_id => "0000-00-01"
    end

    it 'does not succeed, with a 409' do
      last_response.status.should eq 409
    end

    it 'returns a list of valid players' do
      @document = MultiJson.load(last_response.body)
      @document.should eq ['1234-56-78']
    end

    it 'sends no events' do
      pusher.events.should be_empty
    end
  end

  context 'POST to /games/:code/winner when you are not czar' do
    before do
      @game = Game.new
      @game.add_player("abcd-ef-gh")
      @game.add_player("1234-56-78")
      @game.answer("1234-56-78", ['A Card'])
      @game.save
      SecureRandom.stubs(:uuid).returns('1234-56-78')

      post '/games/aaaaa/winner', :player_id => "1234-56-78"
    end

    it 'fails with a 403' do
      last_response.status.should eq 403
    end

    it 'sends no body' do
      last_response.body.should be_empty
    end

    it 'sends no events' do
      pusher.events.should be_empty
    end
  end
end
