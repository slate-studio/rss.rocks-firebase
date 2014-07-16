

###
--------------------------------------------
     Begin subscription.coffee
--------------------------------------------
###
class Subscription
  constructor: (@$rootEl, @snapshot) ->
    @_render()
    @_ui()
    @_bind()

  _render: ->
    @ref  = @snapshot.ref()
    @data = @snapshot.val()
    @$el = $ """
      <li class='subscriptions-list-item'>
        <a href='#' class='subscriptions-remove-button'>&times;</a> #{@data.name} — <a href='#{@data.url}' target='_blank'>#{@data.url}</a>
      </li>
    """
    @$rootEl.append @$el

  _ui: ->
    @$deleteBtn = @$el.find('.subscriptions-remove-button')

  _bind: ->
    @$deleteBtn.on 'click',      (e) => @remove() ; false
    @$deleteBtn.on 'mouseenter', (e) -> $(e.currentTarget).parent().addClass 'striked-out'
    @$deleteBtn.on 'mouseleave', (e) -> $(e.currentTarget).parent().removeClass 'striked-out'

  _unbind: ->
    @$deleteBtn.off()

  remove: ->
    if confirm('Remove subscription?')
      @ref.remove()
      @destroy()

  destroy: ->
    @_unbind()
    @$el.remove()

###
--------------------------------------------
     Begin dashboard.coffee
--------------------------------------------
###
class Dashboard
  constructor: (@$rootEl, @firebase) ->
    @subscriptionCollection = []
    @_render()
    @_ui()
    @_bind()

  _render: ->
    @$rootEl.append """
      <section id='dash' style='display:none;'>
        <p><span id='dash_email'></span> — <a id='dash_logout_btn' href='#'>logout</a></p>

        <div id='subscriptions'>
          <p>
            <form id='subscriptions_new_form'>
              <input id='subscriptions_new_name' placeholder='name' />
              <input id='subscriptions_new_url' placeholder='rss feed link' type='url' />
              <input id='subscriptions_new_submit' value='Add' type='submit' />
            </form>
          </p>
          <ul id='subscriptions_list' class='subscriptions-list'></ul>
        </div>
      </section>
    """

  _ui: ->
    @$el        = $ '#dash'
    @$email     = $ '#dash_email'
    @$logoutBtn = $ '#dash_logout_btn'
    @$newForm   = $ '#subscriptions_new_form'
    @$newUrl    = $ '#subscriptions_new_url'
    @$newName   = $ '#subscriptions_new_name'
    @$list      = $ '#subscriptions_list'

  show: ->
    @uid = app.user.uid

    @subscriptionsRef = @firebase.child('subscriptions').child(@uid)
    @subscriptionsRef.on 'child_added', (snapshot) =>
      @subscriptionCollection.push(new Subscription(@$list, snapshot))

    @$el.show()

  hide: ->
    $.each @subscriptionCollection, (i, el) -> el.destroy()
    @subscriptionsRef.off()

    delete @subscriptionsRef
    delete @uid

    @$el.hide()

  _bind: ->
    @$logoutBtn.on       'click',       (e)        -> app.authView.logout() ; false
    @$newForm.on         'submit',      (e)        => @addNewSubscription() ; false

  setEmail: (email) -> @$email.html(email)

  addNewSubscription: ->
    url  = @$newUrl.val()  ; @$newUrl.val('')
    name = @$newName.val() ; @$newName.val('')

    @subscriptionsRef.push({url: url, name: name})

    @$newName.focus()


###
--------------------------------------------
     Begin authentication.coffee
--------------------------------------------
###
class Authentication
  constructor: (@$rootEl, @firebase, @onAuthCb) ->
    @_render()
    @_ui()
    @_bind()
    @_authenticate()

  _render: ->
    @$rootEl.append """
      <section id='auth' style='display:none;'>
        <p>Welcome to <strong>RSS.rocks</strong>!</p>

        <div id='signup' style='display:none;'>
          <form id='signup_form'>
            <input id='signup_email' value='' placeholder='email' type='email' required>
            <input id='signup_password' value='' placeholder='password' type='password' required>
            <input id='signup_submit' value='signup' type='submit'>
            <span id='signup_loading' style='display:none;'>please wait...</span>
          </form>
          <p id='signup_error' class='error'></p>
          <p>— if you have an account, please <a id='signup_login_btn' href='#'>login</a></p>
        </div>

        <div id='login'>
          <form id='login_form'>
            <input id='login_email' value='' placeholder='email' type='email' required>
            <input id='login_password' value='' placeholder='password' type='password' required>
            <input id='login_submit' value='login' type='submit'>
            <span id='login_loading' style='display:none;'>please wait...</span>
          </form>
          <p id='login_error' class='error'></p>
          <p>— if you don't have an account, please <a id='login_signup_btn' href='#'>signup</a><br>
          — if you forgot your password, <a id='login_reset_password' href='#'>reset</a> it via an email</p>
        </div>
      </section>
    """

  _ui: ->
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

  _bind: ->
    @$loginBtn.on   'click',  (e) => @showLogin()  ; false
    @$signupBtn.on  'click',  (e) => @showSignup() ; false
    @$signupForm.on 'submit', (e) => @signup()     ; false
    @$loginForm.on  'submit', (e) => @login()      ; false

  _authenticate: ->
    @auth = new FirebaseSimpleLogin @firebase, (error, user) =>
      @$loginLoading.hide()

      if user
        @$loginEmail.val('')
        @$loginPass.val('')

        @onAuthCb?(user)
      else app.show(this)

      if error then @error(error.message.replace('FirebaseSimpleLogin: ', ''))

  show: ->
    @$signupError.html('')
    @$loginError.html('')
    @$el.show()

  hide: ->
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
    delete app.user
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
        @$signupEmail.val('')
        @$signupPass.val('')
        @onAuthCb?(user)

  error: (msg) ->
    @$signupError.html(msg)
    @$loginError.html(msg)


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

  ui: ->
    @$el = $('#app')

  render: ->
    @dashView = new Dashboard @$el, @firebase
    @authView = new Authentication @$el, @firebase, (@user) =>
      @dashView.setEmail(@user.email)
      @show(@dashView)

  show: (view) ->
    @currentView?.hide()
    @currentView = view
    @currentView.show()

###
--------------------------------------------
     Begin _main.coffee
--------------------------------------------
###
$ ->
  firebaseAppName = 'sizzling-fire-6443'
  window.app = new App(firebaseAppName)