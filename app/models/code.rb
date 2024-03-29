class Code
  class << self
    attr_accessor :rng
  end

  self.rng = SecureRandom

  def initialize(digits = 5)
    upper = 36**digits
    lower = 36**(digits-1)

    random = rng.random_number(upper - lower)
    base = random + lower
    @code = base.to_s(36).downcase
  end

  def set(code)
    @code = code.to_s.downcase
    self
  end

  def rng
    self.class.rng
  end

  def to_s
    @code
  end

  def ==(other)
    to_s == other.to_s
  end
end
