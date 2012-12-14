class HomeView extends Backbone.View
  events:
    'click .new-game': 'newGame'
    'click .join-game': 'joinGame'

  initialize: ->
    @collection.on('add', @startGame)

  startGame: (game) =>
    new GameView(el: 'body', model: game).render()

  newGame: ->
    @collection.create({}, {wait: true})

  joinGame: ->
    @collection.get(code)

class Game extends Backbone.Model
  is_czar: (player_id) ->
    player_id == @get('czar')

class window.GameCollection extends Backbone.Collection
  model: Game
  url: '/games'

class GameView extends Backbone.View
  render: ->
    @$el.html(JST['game']())
    new InformationView(el: '#information', model: @model).render()
    new PlayAreaView(el: '#playarea', model: @model).render()

class InformationView extends Backbone.View
  render: ->
    @$el.html(JST['information'](code: @model.get('code'), players: @model.get('players')))

class PlayAreaView extends Backbone.View
  render: ->
    if @model.is_czar($.cookie('player_id'))
      new CzarView(el: '#playarea', model: @model).render()
    else
      new HandView(el: '#playarea', model: @model).render()

class CzarView extends Backbone.View
  render: ->
    @$el.addClass("czar")

class HandView extends Backbone.View
  render: ->
    @$el.removeClass("czar")

jQuery ->
  new HomeView(el: 'body', collection: new GameCollection()).render()

