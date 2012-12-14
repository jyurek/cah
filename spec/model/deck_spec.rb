require 'spec_helper'
require 'tempfile'

describe Deck do
  it 'loads in the CSV containing cards' do
    t = Tempfile.new("cards")
    t.puts "one;maybe;eagle"
    t.puts "two;good;fish"
    t.puts "three;bad;bear"
    t.rewind
    deck = Deck.new(t.path)

    deck.cards.should == %w(one two three)
  end
end
