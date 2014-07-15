class Dashboard
  constructor: (@$rootEl, @firebase) ->
    @subscriptionsRef = @firebase.child('subscriptions')

    @render()
    @ui()
    @bind()

  render: ->
    @$rootEl.append """
      <section id='dash' style='display:none;'>
        <p><span id='dash_email'></span> — <a id='dash_logout_btn' href='#'>logout</a></p>

        <div id='subscriptions'>
          <p>
            <span id='subscriptions_empty'>You don't have any subscriptions just yet.<br/></span>
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

  renderSubscription: (doc) -> new Subscription(@$list, doc)

  ui: ->
    @$el        = $ '#dash'
    @$email     = $ '#dash_email'
    @$logoutBtn = $ '#dash_logout_btn'
    @$newForm   = $ '#subscriptions_new_form'
    @$newUrl    = $ '#subscriptions_new_url'
    @$newName   = $ '#subscriptions_new_name'
    @$list      = $ '#subscriptions_list'
    @$empty     = $ '#subscriptions_empty'
    @$items     = $ '.subscriptions-remove-button'

  open: ->
    @$el.show()

  close: ->
    @$el.hide()

  bind: ->
    @subscriptionsRef.on 'child_added', (snapshot) => @renderSubscription(snapshot) ; @$empty.hide()
    @$logoutBtn.on       'click',       (e)        -> app.authView.logout() ; false
    @$newForm.on         'submit',      (e)        => @addNewSubscription() ; false

  setEmail: (email) -> @$email.html(email)

  addNewSubscription: ->
    uid  = app.user.id
    url  = @$newUrl.val()  ; @$newUrl.val('')
    name = @$newName.val() ; @$newName.val('')

    @subscriptionsRef.push({user_id: uid, url: url, name: name})

    @$newName.focus()
