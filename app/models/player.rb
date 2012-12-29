class Player
  attr_accessor :cards, :existing_player

  def initialize(cards = [])
    @cards = cards
    @existing_player = false
  end

  def to_json(state = nil)
    MultiJson.dump(@cards)
  end

  def ==(other)
    @cards = other.cards
  end
end

