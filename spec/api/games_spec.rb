require 'spec_helper'

describe 'Games' do
  context 'POST to /games' do
    it 'the new game in JSON form' do
      post '/games'
      last_response.status.should == 200

      document = JSON.parse(last_response.body)
      document.code.should_not be_nil
    end
  end
end
