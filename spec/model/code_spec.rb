require 'spec_helper'

describe Code do
  it 'generates a code based on a random number' do
    Code.rng = NotSoRandomNumberGenerator.new(1)
    Code.new.to_s.should == "10001"
  end
end
