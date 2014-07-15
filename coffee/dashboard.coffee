class Dashboard
  constructor: (@$rootEl) ->
    @render()
    @ui()
    @bind()

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

  open: ->
    @$el.show()

  close: ->
    @$el.hide()

  bind: ->
    @$logoutBtn.on 'click', (e) -> app.authView.logout() ; false

  setUser: (@user) ->
    @$email.html(@user.email)
