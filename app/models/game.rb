class Game
  attr_accessor :code, :players, :czar, :current_black_card

  def initialize(player = nil)
    @players = [player].compact
    @code = Code.new.to_s
    @czar = player

    @white_cards = Deck.new("data/white_cards").to_a.shuffle
    @black_cards = Deck.new("data/black_cards").to_a.shuffle
  end

  def self.find(code)
    game = Game.new
    game.load(code)
    game
  end

  def start
    @current_black_card = @black_cards.pop
  end

  def save
    store("players", @players)
    store("white", @white_cards)
    store("black", @black_cards)
    store("code", @code)
    store("czar", @czar)
    store("current_black_card", @current_black_card)
  end

  def store(key, value)
    storage.store(key, value)
  end

  def load(code)
    @code = code
    @players = fetch("players")
    @white_cards = fetch("white")
    @black_cards = fetch("black")
    @czar = fetch("czar")
    @current_black_card = fetch("current_black_card")
  end

  def fetch(key)
    storage.fetch(key)
  end

  def storage
    @storage ||= Storage.new("game:#{code}")
  end

  def key(extra)
    "game:#{code}:#{extra}"
  end

  def to_json
    MultiJson.dump(
      code: code.to_s,
      current_black_card: current_black_card,
      players: players,
      czar: czar
    )
  end
end
