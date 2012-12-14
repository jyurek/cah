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

  def fetch(subkey)
    send("fetch_#{REDIS.type(key(subkey))}", subkey)
  end

  def fetch_string(subkey)
    REDIS.get(key(subkey))
  end

  def fetch_list(subkey)
    REDIS.lrange(key(subkey), 0, -1)
  end
end
