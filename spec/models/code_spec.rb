require 'spec_helper'

describe Code do
  it 'generates a code based on a random number' do
    Code.rng = NotSoRandomNumberGenerator.new(15596434)
    Code.new.to_s.should == "aaaaa"
  end

  it 'can be set to a code with .set' do
    code = Code.new.set('12345')
    code.to_s.should eq '12345'
  end

  it 'interpolates as just the code' do
    "#{Code.new.set("12345")}".should eq "12345"
  end
end
