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
end
