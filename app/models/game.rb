class Game
  class << self
    attr_accessor :white_card_path
    attr_accessor :black_card_path
  end
  self.white_card_path = "data/white_cards"
  self.black_card_path = "data/black_cards"

  attr_accessor :code, :players, :play_order, :current_black_card, :storage, :white_cards, :black_cards, :answers, :score

  def initialize
    @code = Code.new
    @play_order = []
    @players = {}
    @answers = {}
    @score = {}
  end

  def self.find(code)
    game = Game.new
    game.load(code)
    game
  end

  def store(key, value)
    storage.store(key, value)
  end

  def fetch(key)
    storage.fetch(key)
  end

  def storage
    @storage ||= Storage.new("game:#{code}")
  end

  def save
    storage.store("code", code)
    storage.store("current_black_card", current_black_card)
    storage.store("black_cards", black_cards)
    storage.store("white_cards", white_cards)
    storage.store("play_order", play_order)
    storage.store("players", players)
    storage.store("score", score)
    storage.store("answers", MultiJson.dump(answers))
  end

  def load(code)
    @code = Code.new.set(code)
    @white_cards = Deck.new(storage.fetch("white_cards"))
    @black_cards = Deck.new(storage.fetch("black_cards"))
    @current_black_card = storage.fetch("current_black_card")
    @play_order = storage.fetch("play_order") || []
    @score = storage.fetch("score") || {}
    @players = {}
    (storage.fetch("players") || []).each do |key, val|
      @players[key] = Player.new(val)
    end
    @answers = MultiJson.load(storage.fetch("answers") || "{}")
  end

  def start_new_round
    @current_black_card = black_cards.draw
    current_czar = @play_order.shift
    @answers = {}
    @play_order.push(current_czar)
    players.each do |player_id, player|
      deal_hand_to(player)
    end
  end

  def is_playing?(player)
    self.players.has_key?(player)
  end

  def is_czar?(player)
    play_order.first == player
  end

  def add_player(player_id)
    player = self.players[player_id] || Player.new
    if play_order.include?(player_id)
      player.existing_player = true
    else
      play_order << player_id
    end
    self.players[player_id] = player
    player
  end

  def player_has_answered?(player)
    self.answers.has_key?(player)
  end

  def player_has_cards?(player, cards)
    Array(cards).all? do |card|
      self.players[player].cards.include?(card)
    end
  end

  def answer(player, new_answers)
    new_answers = Array(new_answers)
    players[player].play_cards(new_answers)
    @answers[player] = new_answers
  end

  def hand_winner(player)
    score[player] ||= 0
    score[player] += 1
    answers[player]
  end

  def white_cards
    @white_cards ||= Deck.load(self.class.white_card_path)
  end

  def black_cards
    @black_cards ||= Deck.load(self.class.black_card_path)
  end

  def current_black_card
    @current_black_card ||= black_cards.draw
  end

  def deal_hand_to(player)
    hand_size = player.cards.length
    (hand_size...10).each do
      player.cards << white_cards.draw
    end
  end

  def czar
    players[play_order.first]
  end

  def to_json(state = nil)
    MultiJson.dump(to_hash)
  end

  def to_hash
    {
      code: code.to_s,
      current_black_card: current_black_card,
      players: players,
      play_order: play_order,
      answers: answers,
      score: score
    }
  end
end
