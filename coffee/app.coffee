class App
  constructor: (@firebaseAppName) ->
    @firebase = new Firebase("https://#{@firebaseAppName}.firebaseio.com")

    @ui()
    @render()

    @authenticate()

  ui: ->
    @$el = $('#app')

  render: ->
    @dashView = new DashView(@$el)
    @authView = new AuthView(@$el)

  authenticate: ->
    @firebaseAuth = new FirebaseSimpleLogin @firebase, (error, user) =>
      if user
        @authView.close()
        @dashView.open(user)
      else
        @dashView.close()
        @authView.open()

      if error
        errorMsg = error.message.replace('FirebaseSimpleLogin: ', '')
        @authView.error(errorMsg)