

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
    @uid       = app.user.uid
    @userEmail = app.user.email

    @$email.html(@userEmail)

    @subscriptionsRef = @firebase.child('users').child(@uid).child('subscriptions')
    @subscriptionsRef.on 'child_added', (snapshot) =>
      @subscriptionCollection.push(new Subscription(@$list, snapshot))

    @$el.show()

  hide: ->
    $.each @subscriptionCollection, (i, el) -> el.destroy()
    @subscriptionsRef.off()

    delete @uid
    delete @userEmail
    delete @subscriptionsRef

    @$el.hide()

  _bind: ->
    @$logoutBtn.on 'click',  (e) -> app.authView.logout() ; false
    @$newForm.on   'submit', (e) => @addNewSubscription() ; false

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
    @usersRef = @firebase.child('users')

    @_render()
    @_ui()
    @_bind()
    @_authenticate()

  _render: ->
    @$rootEl.append """
      <section id='auth' style='display:none;'>
        <p>Welcome to <strong>RSS.rocks</strong>!</p>

        <form id='auth_form'>
          <input id='auth_email' value='' placeholder='email' type='email' required>
          <input id='auth_password' value='' placeholder='password' type='password' required>
          <input id='auth_submit' value='login' type='submit'>

          <span id='auth_loading' style='display:none;'>please wait...</span>
        </form>
        <p id='auth_error' class='error'></p>
        <p id='auth_signup_info'>— if you have an account, please <a id='auth_login_btn' href='#'>login</a></p>
        <p id='auth_login_info'>— if you don't have an account, please <a id='auth_signup_btn' href='#'>signup</a><br>
          — if you forgot your password, <a id='auth_reset_password' href='#'>reset</a> it via an email</p>
      </section>
    """

  _ui: ->
    @$el         = $ '#auth'
    @$form       = $ '#auth_form'
    @$email      = $ '#auth_email'
    @$password   = $ '#auth_password'
    @$submitBtn  = $ '#auth_submit'
    @$loading    = $ '#auth_loading'
    @$error      = $ '#auth_error'

    @$loginBtn   = $ '#auth_login_btn'
    @$signupBtn  = $ '#auth_signup_btn'
    @$resetBtn   = $ '#auth_reset_password'

    @$loginInfo  = $ '#auth_login_info'
    @$signupInfo = $ '#auth_signup_info'

  _bind: ->
    @$loginBtn.on  'click',  (e) => @showLogin()          ; false
    @$signupBtn.on 'click',  (e) => @showSignup()         ; false
    @$resetBtn.on  'click',  (e) => @resetPassword()      ; false
    @$form.on      'submit', (e) => @formSubmitCallback() ; false

  _authenticate: ->
    @auth = new FirebaseSimpleLogin @firebase, (error, user) =>
      @$loading.hide()

      if user
        @onAuthCb?(user)
      else
        app.show(this)

      if error
        @error(error.message.replace('FirebaseSimpleLogin: ', ''))

  signup: ->
    email    = @$email.val()
    password = @$password.val()

    @$loading.show()

    @auth.createUser email, password, (error, user) =>
      @$loading.hide()

      if error
        @error(error.message.replace('FirebaseSimpleLogin: ', ''))
      else
        @usersRef.child(user.uid).child('email').set(user.email)

        @onAuthCb?(user)

  login: ->
    @$loading.show()

    @auth.login 'password', {
      email: @$email.val(),
      password: @$password.val(),
      rememberMe: true
    }

  show: ->
    @showLogin()
    @$el.show()

    @$email.focus()

  hide: ->
    @$el.hide()

  showLogin: ->
    @formSubmitCallback = @login
    @$submitBtn.val('login')
    @$loginInfo.show()
    @$signupInfo.hide()
    @$error.html('')

  showSignup: ->
    @formSubmitCallback = @signup
    @$submitBtn.val('signup')
    @$signupInfo.show()
    @$loginInfo.hide()
    @$error.html('')

  logout: ->
    @auth.logout() ; delete app.user

    @$email.val('')
    @$password.val('')
    @$error.html('')

    app.show(this)

  error: (msg) ->
    @$error.html(msg)

  resetPassword: ->
    # todo: add functionality
    # auth.sendPasswordResetEmail(email, function(error, success) {
    #   if (!error) {
    #     console.log('Password reset email sent successfully');
    #   }
    # });

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
  firebaseAppName = 'rss-rocks'
  window.app = new App(firebaseAppName)