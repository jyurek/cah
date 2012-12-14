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
    console.log $('.join-code').val()
    game = new Game(id: $('.join-code').val())
    game.fetch()
    @collection.add(game)

class Game extends Backbone.Model
  initialize: ->
    @pusher = new Pusher('0174638fca8826a47603', encrypted: true)
    @on 'change:code', @subscribe

  urlRoot: ->
    'games'

  code: ->
    @get('code')

  is_czar: (player_id) ->
    player_id == @get('czar')

  subscribe: =>
    @channel = @pusher.subscribe(@code())
    @channel.bind 'cah:new_player', (data) =>
      $(@).trigger('new_player', data)


class GameCollection extends Backbone.Collection
  model: Game
  url: '/games'

class GameView extends Backbone.View
  initialize: ->

  render: ->
    @$el.html(JST['game']())
    new InformationView(el: '#information', model: @model).render()
    new PlayAreaView(el: '#playarea', model: @model).render()

class InformationView extends Backbone.View
  initialize: ->
    $(@model).on('new_player', @newPlayer)

  newPlayer: (event, player_id) =>
    console.log player_id
    @model.get('players').push player_id
    @render()

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

