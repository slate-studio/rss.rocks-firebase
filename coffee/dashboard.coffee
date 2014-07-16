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
    console.log 'test'
    $.each @subscriptionCollection, (i, el) -> console.log el ; el.destroy()
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
