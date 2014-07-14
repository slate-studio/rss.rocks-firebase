class App
  constructor: (@firebaseAppName) ->
    @firebase = new Firebase("https://#{@firebaseAppName}.firebaseio.com")

    @createViews()
    @authenticate()

  createViews: ->
    @dashView = new DashView()
    @authView = new AuthView()

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