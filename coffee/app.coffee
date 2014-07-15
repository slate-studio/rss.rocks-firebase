class App
  constructor: (@firebaseAppName) ->
    @firebase = new Firebase("https://#{@firebaseAppName}.firebaseio.com")

    @ui()
    @render()

  ui: ->
    @$el = $('#app')

  render: ->
    @dashView = new Dashboard @$el
    @authView = new FirebaseAuth @$el, @firebase, (user) =>
      @dashView.setUser(user)
      @show(@dashView)

  show: (view) ->
    @currentView?.close()
    @currentView = view
    @currentView.open()