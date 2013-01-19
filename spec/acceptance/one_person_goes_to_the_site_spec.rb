require 'spec_helper'

feature 'One person goes to the site' do
  background do
    SecureRandom.stubs(uuid: 'something')
  end

  scenario 'having never visited before, and gets a cookie' do
    user_has_never_visited_before
    user_goes_to_the_site
    user_has_a_player_id_cookie_set
  end

  def user_has_never_visited_before
    Capybara.reset_session!
  end

  def user_goes_to_the_site
    visit '/'
  end

  def user_has_a_player_id_cookie_set
    cookie = get_me_the_cookie('player_id') || {}
    cookie[:value].should == "something"
  end
end
