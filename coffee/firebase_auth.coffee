class FirebaseAuth
  constructor: (@$rootEl, @firebase, @onAuthCb) ->
    @render()
    @ui()
    @bind()
    @authenticate()

  render: ->
    @$rootEl.append """
      <section id='auth' style='display:none;'>
        <p>Welcome to <strong>RSS.rocks</strong>!</p>

        <div id='signup' style='display:none;'>
          <form id='signup_form'>
            <input id='signup_email' value='' placeholder='email' type='email'>
            <input id='signup_password' value='' placeholder='password' type='password'>
            <input id='signup_submit' value='signup' type='submit'>
            <span id='signup_loading' style='display:none;'>please wait...</span>
          </form>
          <p id='signup_error' class='error'></p>
          <p>— if you have an account, please <a id='signup_login_btn' href='#'>login</a></p>
        </div>

        <div id='login'>
          <form id='login_form'>
            <input id='login_email' value='' placeholder='email' type='email'>
            <input id='login_password' value='' placeholder='password' type='password'>
            <input id='login_submit' value='login' type='submit'>
            <span id='login_loading' style='display:none;'>please wait...</span>
          </form>
          <p id='login_error' class='error'></p>
          <p>— if you don't have an account, please <a id='login_signup_btn' href='#'>signup</a><br>
          — if you forgot your password, <a id='login_reset_password' href='#'>reset</a> it via an email</p>
        </div>
      </section>
    """

  ui: ->
    @$el            = $('#auth')
    @$loginBtn      = $('#signup_login_btn')
    @$signupBtn     = $('#login_signup_btn')
    @$loginView     = $('#login')
    @$signupView    = $('#signup')
    @$loginForm     = $('#login_form')
    @$signupForm    = $('#signup_form')
    @$loginEmail    = $('#login_email')
    @$loginPass     = $('#login_password')
    @$signupEmail   = $('#signup_email')
    @$signupPass    = $('#signup_password')
    @$loginError    = $('#login_error')
    @$signupError   = $('#signup_error')
    @$signupLoading = $('#signup_loading')
    @$loginLoading  = $('#login_loading')

  bind: ->
    @$loginBtn.on   'click',  (e) => @showLogin()  ; false
    @$signupBtn.on  'click',  (e) => @showSignup() ; false
    @$signupForm.on 'submit', (e) => @signup()     ; false
    @$loginForm.on  'submit', (e) => @login()      ; false

  authenticate: ->
    @auth = new FirebaseSimpleLogin @firebase, (error, user) =>
      @$loginLoading.hide()

      if user then @onAuthCb?(user) else app.show(this)

      if error then @error(error.message.replace('FirebaseSimpleLogin: ', ''))

  open: ->
    @$signupError.html('')
    @$loginError.html('')
    @$el.show()

  close: ->
    @$el.hide()

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

    @$loginLoading.show()

    @auth.login 'password', { email: email, password: password, rememberMe: true }

  logout: ->
    @auth.logout()
    @showLogin()
    app.show(this)

  signup: ->
    email    = @$signupEmail.val()
    password = @$signupPass.val()

    @$signupLoading.show()

    @auth.createUser email, password, (error, user) =>
      @$signupLoading.hide()

      if error
        @error(error.message.replace('FirebaseSimpleLogin: ', ''))
      else
        @onAuthCb?(user)

  error: (msg) ->
    @$signupError.html(msg)
    @$loginError.html(msg)
