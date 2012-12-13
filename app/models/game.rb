class Game
  attr_accessor :code, :players

  def initialize
    @players = []
    @code = Code.new
  end
end
