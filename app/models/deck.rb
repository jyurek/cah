require 'csv'

class Deck
  attr_accessor :cards

  def initialize(cards = [])
    @cards = cards.dup.compact
  end

  def self.load(filename)
    csv = CSV.open(filename, col_sep: ';')
    @cards = []
    csv.each do |card|
      @cards << card[0]
    end
    Deck.new(@cards[1..-1]).shuffle
  end

  def shuffle
    @cards = @cards.shuffle
    self
  end

  def to_a
    @cards
  end

  def draw
    @cards.pop
  end

  def ==(other)
    @cards == other.cards
  end
end
