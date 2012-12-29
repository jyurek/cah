require 'spec_helper'

feature 'Four people play a game', js: true do
  scenario 'where one creates it and the other joins' do
    code = player_one_starts_a_game
    player_joins_the_game_with_code("2", code)
    player_joins_the_game_with_code("3", code)
    player_joins_the_game_with_code("4", code)

    p2_card = player_selects_a_card("2")
    p3_card = player_selects_a_card("3")
    p4_card = player_selects_a_card("4")

    player_one_should_see_there_are_answers
    player_one_starts_reading_answers(p2_card, p3_card, p4_card)

    p [p2_card, p3_card, p4_card]
  end

  def player_one_starts_a_game
    as_player("1") do
      visit('/')
      click_link("Start New Game")
      page.find(".code").text
    end
  end

  def player_one_should_see_there_are_answers
    as_player('1') do
      within(".answers") do
        page.should have_content('3 of 3')
      end
    end
  end

  def player_one_starts_reading_answers(*answers)
    as_player('1') do
      click_button "Read Answers"
      within(".answers") do
        answers.each do |answer|
          page.should have_content(answer)
        end
      end
    end
  end

  def player_joins_the_game_with_code(player, code)
    as_player(player) do
      visit '/'
      fill_in("code", with: code)
      click_link "Join Game"

      page.should have_css(".playarea")
    end
  end

  def player_selects_a_card(player)
    as_player(player) do
      cards = page.all(".card")
      card = cards.sample
      card.click
      click_button("Use This Answer")
      card.text
    end
  end

  private

  def as_player(which, &block)
    using_session(which, &block)
  end
end

