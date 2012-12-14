class Game
  attr_accessor :code, :players, :czar

  def initialize(player)
    @players = [player]
    @code = Code.new
    @czar = player

    @white_cards = Deck.new("data/white_cards")
    @black_cards = Deck.new("data/black_cards")

    save
  end

  def save
    store("players", @players)
    store("white", @white_cards)
    store("black", @black_cards)
    store("code", @code)
    store("czar", @czar)
  end

  def store(key, value)
    @storage ||= Storage.new("game:#{code}")
    @storage.store(key, value)
  end

  def key(extra)
    "game:#{code}:#{extra}"
  end

  def to_json
    MultiJson.dump(
      code: code.to_s,
      players: players,
      czar: czar
    )
  end
end
