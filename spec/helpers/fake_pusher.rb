class FakePusher
  def initialize
    @events = []
  end

  def trigger(*args)
    @events << args
  end

  def events
    @events
  end
end
