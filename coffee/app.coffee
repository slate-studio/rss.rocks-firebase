class App
  constructor: (@firebaseAppName) ->
    @firebase = new Firebase("https://#{@firebaseAppName}.firebaseio.com")

    @ui()
    @render()

  ui: ->
    @$el = $('#app')

  render: ->
    @dashView = new Dashboard @$el, @firebase
    @authView = new Authentication @$el, @firebase, (@user) =>
      @dashView.setEmail(@user.email)
      @show(@dashView)

  show: (view) ->
    @currentView?.close()
    @currentView = view
    @currentView.open()