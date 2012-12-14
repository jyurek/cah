require 'spec_helper'

describe Storage do
  Storage::REDIS = Redis.new(:host => "localhost", :port => 6379)

  it 'initializes with a partial key' do
    store = Storage.new("abcd")
    store.key.should eq "abcd"
    store.key("1234").should eq "abcd:1234"
  end

  it 'can store strings in redis' do
    Storage::REDIS.del("abcd:string")
    store = Storage.new("abcd")
    store.store("string", "something")

    Storage::REDIS.get("abcd:string").should eq "something"
  end

  it 'can store arrays in redis' do
    Storage::REDIS.del("abcd:array")
    store = Storage.new("abcd")
    store.store("array", %w(one two three))

    Storage::REDIS.lrange("abcd:array", 0, -1).should eq %w(one two three)
  end

  it 'can load a string from Redis' do
    Storage::REDIS.del("abcd:string")
    Storage::REDIS.set("abcd:string", "this is a string")
    store = Storage.new("abcd")

    store.fetch("string").should eq "this is a string"
  end

  it 'can load an array from Redis' do
    Storage::REDIS.del("abcd:array")
    Storage::REDIS.rpush("abcd:array", "val1")
    Storage::REDIS.rpush("abcd:array", "val2")
    Storage::REDIS.rpush("abcd:array", "val3")
    store = Storage.new("abcd")

    store.fetch("array").should eq %w(val1 val2 val3)
  end
end
