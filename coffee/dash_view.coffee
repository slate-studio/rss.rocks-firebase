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