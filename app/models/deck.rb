require 'csv'

class Deck
  attr_accessor :cards

  def initialize(filename)
    csv = CSV.open(filename, col_sep: ';')
    @cards = []
    csv.each do |card|
      @cards << card[0]
    end
  end

  def to_a
    @cards
  end
end
