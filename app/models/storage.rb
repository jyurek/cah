class Storage

  REDIS = Redis.new(:host => "localhost", :port => 6379)

  def initialize(key)
    @key = key
  end

  def key(subkey = nil)
    [@key, subkey].compact.join(":")
  end

  def store(subkey, value)
    type = value.class.name.downcase
    send("store_#{type}", subkey, value)
  end

  def store_string(subkey, value)
    REDIS.set(key(subkey), value)
  end

  def store_array(subkey, values)
    values.each do |value|
      REDIS.rpush(key(subkey), value)
    end
  end

  def store_deck(subkey, value)
    store_array(subkey, value.to_a)
  end

  def store_code(subkey, value)
    store_string(subkey, value.to_s)
  end
end
