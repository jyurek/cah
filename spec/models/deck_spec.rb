require 'spec_helper'
require 'tempfile'

describe Deck do
  it 'loads in the CSV containing cards' do
    t = Tempfile.new("cards")
    t.puts "English;Undecided;Animals"
    t.puts "one;maybe;eagle"
    t.puts "two;good;fish"
    t.puts "three;bad;bear"
    t.rewind
    deck = Deck.load(t.path)

    deck.cards.sort.should eq %w(one three two)
  end

  it 'gets rid of nil cards' do
    deck = Deck.new([1,2,nil,3])
    deck.cards.sort.should eq [1,2,3]
  end

  it 'can draw a card' do
    deck = Deck.new(%w(one two three))
    card = deck.draw
    (deck.cards + [card]).sort.should eq %w(one three two)
  end
end
