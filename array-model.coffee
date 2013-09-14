
if !Object.defineProperty
  throw new Error 'Object.defineProperty is not found'

if !Array::model then Object.defineProperty Array.prototype, 'model',
  enumerable: false
  value: () ->
    for prop in ['_bindAll', '_watchers', '_trigger', '_bindTo', '_model', '_get', '_set', 'ext', 'model']
      Object.defineProperty @, prop,
        value: 0
        enumerable: false
        writable: true

    @_watchers =
      add: []
      remove: []
      change: []

    # set & get handlers
    @_get = null
    @_set = null

    @ext = yes

    @_model = []

    # extend array by ExtRaay methods
    for name, method of ExtArray
      @[name] = method

    @_bindTo = 0
    @_bindAll()

    this

ExtArray = {}

# mutator methods

ExtArray._pop = Array::pop
ExtArray.pop = () ->
  item = @_pop()
  @_bindAll()
  @_trigger 'remove', item
  @_trigger 'change'
  item

ExtArray._push = Array::push
ExtArray.push = (items...) ->
  if @_set
    for item, i in items
      @_set item, @length + i
  len = @_push items...
  @_bindAll()
  for item, i in items
    @_trigger 'add', item, @length - items.length + i
  @_trigger 'change'
  len

ExtArray._reverse = Array::reverse
ExtArray.reverse = () ->
  @_reverse()
  @_trigger 'change'
  this

ExtArray._shift = Array::shift
ExtArray.shift = () ->
  item = @_shift()
  @_bindAll()
  @_trigger 'remove', item
  @_trigger 'change'
  if @_get
    @_get item, 0
  else
    item

ExtArray._sort = Array::sort
ExtArray.sort = () ->
  @_sort()
  @_trigger 'change'

ExtArray._splice = Array::splice
ExtArray.splice = (offset, len, items...) ->
  if @_set
    for item, i in items
      @_set item, offset + i
  slice = @_slice offset, offset + len
  @_splice offset, len, items...
  @_bindAll()
  for item, i in slice
    @_trigger 'remove', item, offset + i
  for item, i in items
    @_trigger 'add', item, offset + i
  @_trigger 'change'
  slice

ExtArray._unshift = Array::unshift
ExtArray.unshift = (items...) ->
  if @_set
    for item, i in items
      @_set item, i
  len = @_unshift items...
  @_bindAll()
  for item in items
    @_trigger 'add', item, i
  @_trigger 'change'
  len

# accessor methods

ExtArray._concat = Array::concat
ExtArray.concat = (args...) ->
  @_concat args...

ExtArray._join = Array::join
ExtArray.join = (separator) ->
  @_join separator

ExtArray._slice = Array::slice
ExtArray.slice = (offset, offset2) ->
  @_slice offset, offset2

ExtArray._toString = Array::toString
ExtArray.toString = () ->
  @_toString()

ExtArray._indexOf = Array::indexOf
ExtArray.indexOf = (searchIndex, fromIndex) ->
  @_indexOf searchIndex, fromIndex

ExtArray._lastIndexOf = Array::lastIndexOf
ExtArray.lastIndexOf = (searchIndex, fromIndex) ->
  @_lastIndexOf searchIndex, fromIndex

# iteration methods

ExtArray._forEach = Array::forEach
ExtArray.forEach = (callback, arg) ->
  @_forEach callback, arg

ExtArray._every = Array::every
ExtArray.every = (callback, thisObject) ->
  @_every callback, thisObject

ExtArray._some = Array::some
ExtArray.some = (callback, thisObject) ->
  @_some callback, thisObject

ExtArray._filter= Array::filter
ExtArray.filter = (callback, thisObject) ->
  @_filter callback, thisObject

ExtArray._map = Array::map
ExtArray.map = (callback, thisArg) ->
  @_map callback, thisArg

ExtArray._reduce = Array::reduce
ExtArray.reduce = (callback, initialValue) ->
  @_reduce callback, initialValue

ExtArray._reduceRight = Array::reduceRight
ExtArray.reduceRight = (callback, initialValue) ->
  @_reduceRight callback, initialValue

# own methods

ExtArray.add = (item) ->
  @push item

ExtArray.remove = (item) ->
  pos = @indexOf item
  if (pos >= 0)
    @splice pos, 1
  this

ExtArray.replace = (item1, item2) ->
  pos = @indexOf item1
  if (pos >= 0)
    @splice pos, 1, item2
  this

ExtArray.empty = () ->
  @splice 0, @length
  this

ExtArray.on = (event, watcher, first) ->
  if not (event of @_watchers)
    return this
  watchers = @_watchers[event]
  if (typeof watcher) is 'function'
    if first
      watchers.unshift watcher
    else
      watchers.push watcher
  this

ExtArray.off = (event, watcher) ->
  if not event of watchers
    return this
  watchers = @_watchers[event]
  if typeof watcher is 'function'
    pos = watchers.indexOf watcher
    if ~pos
      watchers.splice pos, 1
  else
    watchers.splice 0, watchers.length
  this

ExtArray.get = (handler) ->
  if (typeof handler) is 'function'
    @_get = handler
  else
    @_get = null
  this

ExtArray.set = (handler) ->
  if (typeof handler) is 'function'
    @_set = handler

    for item, i in @_model
      @_set item, i
  else
    @_set = null
  this

ExtArray._trigger = (action, item, itemPos) ->
  watchers = @_watchers[action]
  if not watchers
    return this
  pos = @_indexOf item
  for watcher in watchers
    if action is 'change'
      watcher this
    else
      pos = itemPos or if pos < 0 then undefined else pos
      watcher item, pos, this
  this

ExtArray._bindAll = ->
  model = @_model

  len = @length
  if @_bindTo is len
    return
  if @_bindTo > len
    @_bindTo = len
    return

  while @_bindTo isnt len
    do (pos = @_bindTo++) =>
      val = @[pos]
      Object.defineProperty @, pos,
        get: () =>
          if @_get
            @_get model[pos], pos
          else
            model[pos]
        set: (val) =>
          if @_set
            @_set val, pos
          if @_mutator
            model[pos] = val
          else
            @splice pos, 1, val
          val
        enumerable: true
      @[pos] = val

  this

for name in ['push', 'pop', 'splice', 'shift', 'unshift']
  method = ExtArray[name]
  do (method) ->
    ExtArray[name] = (args...) ->
      @_mutator = yes
      try
        resp = method.apply @, args
      catch e
        @_mutator = no
        throw e
      @_mutator = no
      resp
