require 'spec_helper'

feature 'Two people start a game', js: true do
  scenario 'where one creates it and the other joins' do
    player_one_visits_the_site
    player_one_starts_a_game
    player_one_is_card_czar
    code = player_one_gets_the_code

    player_two_visits_the_site
    player_two_joins_the_game_with_code(code)
    player_one_sees_someone_joined

    player_two_has_10_white_cards
  end

  def player_one_visits_the_site
    as_player_one do
      visit '/'
    end
  end

  def player_one_starts_a_game
    as_player_one do
      click_link("Start New Game")
    end
  end

  def player_one_is_card_czar
    as_player_one do
      page.should have_css("#playarea.czar")
    end
  end

  def player_one_gets_the_code
    as_player_one do
      page.find("#information .code").text
    end
  end

  def player_one_sees_someone_joined
    as_player_one do
      within('#information') do
        page.should have_css(".new_player")
      end
    end
  end

  def player_two_visits_the_site
    as_player_two do
      visit '/'
    end
  end

  def player_two_joins_the_game_with_code(code)
    as_player_two do
      fill_in(".code", with: code)
      click_link "Join Game"
    end
  end

  def player_two_has_10_white_cards
    as_player_two do
      page.should have_css('.card', count: 10)
    end
  end

  private

  def as_player_one(&block)
    using_session("Player 1", &block)
  end

  def as_player_two(&block)
    using_session("Player 2", &block)
  end
end
