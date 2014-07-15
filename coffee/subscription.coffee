class Subscription
  constructor: (@$rootEl, @snapshot) ->
    @render()
    @ui()
    @bind()

  render: ->
    @ref  = @snapshot.ref()
    @data = @snapshot.val()
    @$el = $ """
      <li class='subscriptions-list-item'>
        <a href='#' class='subscriptions-remove-button'>&times;</a> #{@data.name} — <a href='#{@data.url}' target='_blank'>#{@data.url}</a>
      </li>
    """
    @$rootEl.append @$el

  ui: ->
    @$deleteBtn = @$el.find('.subscriptions-remove-button')

  bind: ->
    @$deleteBtn.on 'click',      (e) => @remove() ; false
    @$deleteBtn.on 'mouseenter', (e) -> $(e.currentTarget).parent().addClass 'striked-out'
    @$deleteBtn.on 'mouseleave', (e) -> $(e.currentTarget).parent().removeClass 'striked-out'

  unbind: ->
    @$deleteBtn.off 'click'
    @$deleteBtn.off 'mouseenter'
    @$deleteBtn.off 'mouseleave'

  remove: ->
    if confirm('Remove subscription?')
      @unbind()
      @$el.remove()
      @ref.remove()