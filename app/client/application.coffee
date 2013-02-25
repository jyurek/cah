my_player_id = $.cookie('player_id')
pusher = null;

class HomeView extends Backbone.View
  events:
    'click .new-game': 'newGame'
    'click .join-game': 'loadGame'

  newGame: ->
    $.ajax '/games',
      type: 'POST',
      dataType: "json",
      success: (data) =>
        game = new Game(data)
        game.join()
        game.start()

  loadGame: ->
    game_code = $('.join-code').val()
    $.ajax "/games/#{game_code}",
      type: 'GET',
      dataType: "json",
      success: (data) =>
        game = new Game(data)
        game.join()
        game.start()

class Game
  constructor: (object) ->
    @populateWith(object)
    @events = pusher.subscribe(@code)

  populateWith: (object) ->
    @code = object.code
    @players = object.players
    @play_order = object.play_order
    @current_black_card = object.current_black_card
    @answers = object.answers
    @score = object.score

  fetch: ->
    $.ajax "/games/#{@code}",
      async: false,
      type: "GET",
      dataType: "json",
      success: (data) =>
        @populateWith(data)

  join: ->
    $.ajax "/games/#{@code}/player",
      async: false,
      type: "POST",
      dataType: "json",
      success: (data) =>

  start: ->
    @fetch()
    @gameView ||= new GameView(el: 'body', model: this)
    @gameView.render()

  is_czar: ->
    my_player_id == @play_order[0]

  myCards: ->
    @players[my_player_id]

  removeMyCards: (cards) ->
    @players[my_player_id] = _.difference(@players[my_player_id], cards)

  whitePlayerCount: ->
    Object.keys(@players).length - 1

  answerCount: ->
    Object.keys(@answers).length

  answersReady: ->
    @whitePlayerCount() == @answerCount() && @whitePlayerCount() > 0

class GameView extends Backbone.View
  initialize: ->
    @model.events.bind "cah:answer_submitted", @answerReceived
    @model.events.bind "cah:game_state", @setState

  answerReceived: (data) =>
    @model.answers[data['player']] = data['cards']
    @render()

  setState: (data) =>
    @model.populateWith(data)
    @render()

  render: ->
    @$el.html(JST['game'])
    new InformationView(el: '.information', model: @model).render()
    new PlayAreaView(el: '.playarea', model: @model).render()

class InformationView extends Backbone.View
  initialize: ->
    @model.events.bind "cah:new_player", =>
      @model.fetch()
      @render()

  render: ->
    @$el.html(JST['information'](game: @model))

class PlayAreaView extends Backbone.View
  render: ->
    if @model.is_czar()
      new CzarView(el: '.playarea', model: @model).render()
    else
      new HandView(el: '.playarea', model: @model).render()

class CzarView extends Backbone.View
  events:
    "click .read-answers": "readAnswers"
    "click ol.answers li": "selectAnswer"
    "click .choose-winner": "chooseWinner"

  render: ->
    $('body').addClass("czar")
    @$el.html(JST['czar'](game: @model))
    $('.read-answers').toggle(@model.answersReady())

  readAnswers: ->
    $('.answers').show()
    $('.read-answers').hide()
    $('.choose-winner').show()

  selectAnswer: (event) ->
    $('ol.answers li').removeClass("selected-answer")
    $(event.currentTarget).addClass("selected-answer")

  chooseWinner: ->
    $.ajax "/games/#{@model.code}/winner",
      type: "POST",
      dataType: "json",
      data:
        player_id:
          $('ol.answers .selected-answer').attr('data-player-id')

class HandView extends Backbone.View
  events:
    "click .card" : "selectCard"
    "click .use-cards" : "playCards"

  render: ->
    $('body').removeClass("czar")
    @$el.html(JST['hand'](game: @model))

  selectCard: (event) ->
    target = event.currentTarget
    $(target).toggleClass("selected")
    if $(target).is(".selected")
      $(target).attr("data-click-time", new Date().getTime())
    $(".use-cards").toggle(($(".cards .selected").length > 0))

  playCards: ->
    cards = @selectedCards()
    @model.removeMyCards(cards)
    card_names = _.map cards, (e) ->
      e.innerText
    $.ajax "/games/#{@model.code}/answer",
      type: "POST",
      dataType: "json",
      data:
        card_names:
          card_names
      success: (response) =>

  selectedCards: ->
    cards = $(".cards .selected")
    cards = _.sortBy cards.toArray(), (e) ->
      $(e).attr('data-click-time')

$ ->
  pusher = new Pusher('0174638fca8826a47603', encrypted: true)
  new HomeView(el: 'body')
