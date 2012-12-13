class Game
  attr_accessor :code, :players

  def initialize
    @players = []
    @code = Code.new
  end

  def to_json
    MultiJson.dump(
      code: code.to_s,
      players: players
    )
  end
end
