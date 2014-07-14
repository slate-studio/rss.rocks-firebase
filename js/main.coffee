class AuthView
  constructor: ->
    @el           = $('#auth')
    @signupViewEl = $('#signup')
    @loginViewEl  = $('#login')
    @signupFormEl = $('#signup_form')
    @loginFormEl  = $('#login_form')
    @loginBtn     = $('#signup_login_btn')
    @signupBtn    = $('#login_signup_btn')

    @render()
    @bind()

  render: ->
    @el.show()

  bind: ->
    @loginBtn.on 'click', (e) => @loginViewEl.show() ; @signupViewEl.hide()
    @signupBtn.on 'click', (e) => @signupViewEl.show() ; @loginViewEl.hide()

class App
  constructor: (@firebaseAppName) ->
    @firebase = new Firebase("https://#{@firebaseAppName}.firebaseio.com")
    @auth = new FirebaseSimpleLogin @firebase, (error, user) ->
      if user
      else
        @authView = new AuthView()

$ ->
  firebaseAppName = 'sizzling-fire-6443'
  window.app = new App(firebaseAppName)