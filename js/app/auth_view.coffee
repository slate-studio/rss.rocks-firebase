class AuthView
  constructor: ->
    @ui()
    @bindEvents()

  ui: ->
    @$el          = $('#auth')
    @$loginBtn    = $('#signup_login_btn')
    @$signupBtn   = $('#login_signup_btn')
    @$loginView   = $('#login')
    @$signupView  = $('#signup')
    @$loginForm   = $('#login_form')
    @$signupForm  = $('#signup_form')
    @$loginEmail  = $('#login_email')
    @$loginPass   = $('#login_password')
    @$signupEmail = $('#signup_email')
    @$signupPass  = $('#signup_password')
    @$loginError  = $('#login_error')
    @$signupError = $('#signup_error')

  bindEvents: ->
    @$loginBtn.on   'click',  (e) => @showLogin() ; false
    @$signupBtn.on  'click',  (e) => @showSignup() ; false
    @$signupForm.on 'submit', (e) => @signup() ; false
    @$loginForm.on  'submit', (e) => @login() ; false

  showLogin: ->
    @$loginView.show()
    @$signupView.hide()
    @$loginError.html('')

  showSignup: ->
    @$signupView.show()
    @$loginView.hide()
    @$signupError.html('')

  login: ->
    email    = @$loginEmail.val()
    password = @$loginPass.val()

    app.firebaseAuth.login 'password', {
      email:      email
      password:   password
      rememberMe: true
    }

  signup: ->
    email    = @$signupEmail.val()
    password = @$signupPass.val()

    app.firebaseAuth.createUser email, password, (error, user) =>
      if error
        errorMsg = error.message.replace('FirebaseSimpleLogin: ', '')
        @error(errorMsg)
      else
        @close()
        app.dashView.open(user)

  error: (msg) ->
    @$signupError.html(msg)
    @$loginError.html(msg)

  open: ->
    @$signupError.html('')
    @$loginError.html('')
    @$el.show()

  close: ->
    @$el.hide()