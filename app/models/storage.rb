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
    REDIS.del(key(subkey))
    values.each do |value|
      REDIS.rpush(key(subkey), value)
    end
  end

  def store_hash(subkey, values)
    REDIS.del(key(subkey))
    values.each do |key, value|
      REDIS.hset(key(subkey), key, value.to_json)
    end
  end

  def store_nilclass(subkey, value)
    REDIS.del(key(subkey))
  end

  def store_code(subkey, value)
    store_string(subkey, value.to_s)
  end

  def store_deck(subkey, value)
    store_array(subkey, value.to_a)
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

  def fetch_hash(subkey)
    hash = REDIS.hgetall(key(subkey))
    hash.each do |key, value|
      hash[key] = MultiJson.load(value)
    end
  end

  def fetch_none(subkey)
  end
end
