require 'spec_helper'

feature 'Four people play a game', js: true do
  scenario 'from start to a few rounds in' do
    code = player_one_starts_a_game
    player_joins_the_game_with_code("2", code)
    player_joins_the_game_with_code("3", code)
    player_joins_the_game_with_code("4", code)

    p2_card = player_selects_a_card("2")
    player_one_should_see_there_is_an_answer
    player_one_cannot_read_answers_yet
    p3_card = player_selects_a_card("3")
    p4_card = player_selects_a_card("4")

    player_one_starts_reading_answers(p2_card, p3_card, p4_card)
    player_one_selects_an_answer_as_winner(p3_card)
    player_is_informed_they_won("3")
    players_are_informed_they_lost("2", "4")

    everyone_continues_to_next_round

    player_is_new_card_czar("2")
    player_is_not_card_czar("1")

    player_has_10_cards("1")
    player_has_10_cards("3")
    player_has_10_cards("4")

    fail("Not actually done yet")
  end

  def player_one_starts_a_game
    as_player("1") do
      visit('/')
      click_link("Start New Game")
      page.find(".code").text
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
      card_text = card.text
      click_button("Use This Answer")
      card_text
    end
  end

  def player_one_should_see_there_is_an_answer
    as_player('1') do
      within(".answer_count") do
        page.should have_content('1 of 3')
      end
    end
  end

  def player_one_cannot_read_answers_yet
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

  def player_one_selects_an_answer_as_winner(card)
    as_player("1") do
      page.find("li:contains('#{card}')").click
      page.click_button("Select This Answer")
    end
  end

  def player_is_informed_they_won(player)
    as_player(player) do
      page.should have_css(".announcement:contains('You won this hand!')")
    end
  end

  def players_are_informed_they_lost(*players)
    players.each do |player|
      as_player(player) do
        page.should have_css(".announcement:contains('You didn't win this hand.')")
      end
    end
  end

  def everyone_continues_to_next_round
  end

  def player_is_new_card_czar(player)
  end

  def player_is_not_card_czar(player)
  end

  def player_has_10_cards(player)
  end

  private

  def as_player(which, &block)
    using_session(which, &block)
  end
end

