class DashView
  constructor: ->
    @ui()
    @bindEvents()

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