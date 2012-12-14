require 'spec_helper'

describe Code do
  it 'generates a code based on a random number' do
    Code.rng = NotSoRandomNumberGenerator.new(15596434)
    Code.new.to_s.should == "aaaaa"
  end
end
