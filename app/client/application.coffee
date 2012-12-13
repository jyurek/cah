class HomeView extends Backbone.View
  events:
    'click .new_game': 'newGame'
    'click .join_game': 'joinGame'

  render: ->

  newGame: (e) ->
    alert('fooo')
    new GameView(el: 'body').render()

  joinGame: ->

class GameView extends Backbone.View
  initialize: ->
    _.bindAll @
    @render()

  render: ->
    $(@el).html(JST['game']())

jQuery ->
  new HomeView(el: 'body').render()
