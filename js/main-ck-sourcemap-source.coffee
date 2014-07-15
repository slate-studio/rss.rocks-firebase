

###
--------------------------------------------
     Begin auth_view.coffee
--------------------------------------------
###
class AuthView
  constructor: (@$rootEl) ->
    @render()
    @ui()
    @bindEvents()

  render: ->
    @$rootEl.append """
      <section id='auth' style='display:none;'>
        <p>Welcome to <strong>RSS.rocks</strong>!</p>

        <div id='signup' style='display:none;'>
            <form id='signup_form'>
                <input id='signup_email' value='' placeholder='email' type='email'>
                <input id='signup_password' value='' placeholder='password' type='password'>
                <input id='signup_submit' value='signup' type='submit'>
            </form>
          <p id='signup_error' class='error'></p>
            <p>— if you have an account, please <a id='signup_login_btn' href='#'>login</a></p>
        </div>

        <div id='login'>
          <form id='login_form'>
              <input id='login_email' value='' placeholder='email' type='email'>
              <input id='login_password' value='' placeholder='password' type='password'>
              <input id='login_submit' value='login' type='submit'>
          </form>
          <p id='login_error' class='error'></p>
          <p>— if you don't have an account, please <a id='login_signup_btn' href='#'>signup</a><br>
          — if you forgot your password, <a id='login_reset_password' href='#'>reset</a> it via an email
          </p>
        </div>
      </section>
    """

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

###
--------------------------------------------
     Begin dash_view.coffee
--------------------------------------------
###
class DashView
  constructor: (@$rootEl) ->
    @render()
    @ui()
    @bindEvents()

  render: ->
    @$rootEl.append """
      <section id='dash' style='display:none;'>
        <p><span id='dash_email'></span> — <a id='dash_logout_btn' href='#'>logout</a></p>
      </section>
    """

  ui: ->
    @$el        = $('#dash')
    @$email     = $('#dash_email')
    @$logoutBtn = $('#dash_logout_btn')

  bindEvents: ->
    @$logoutBtn.on 'click', (e) => @logout() ; false

  logout: ->
    app.firebaseAuth.logout()
    @close()
    app.authView.open()
    app.authView.showLogin()

  open: (@user) ->
    @$email.html(@user.email)
    @$el.show()

  close: ->
    @$el.hide()

###
--------------------------------------------
     Begin app.coffee
--------------------------------------------
###
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

###
--------------------------------------------
     Begin main.coffee
--------------------------------------------
###
$ ->
  firebaseAppName = 'sizzling-fire-6443'
  window.app = new App(firebaseAppName)