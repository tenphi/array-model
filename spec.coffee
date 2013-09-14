require './array-model.js'
assert = require('chai').assert

describe 'simple assignment :', ->

  it 'get / set', ->
    model = ['one', 'two', 'three'].model()
    model[1] = 'four'
    assert.equal model.toString(), 'one,four,three'
    assert.equal model[1], 'four'

describe 'simple actions :', ->

  model = ['one', 'two', 'three'].model()

  it 'empty', ->
    model.empty()

  it 'add one item', ->
    model.push 'one'
    assert.equal model[0], 'one'
    model.add 'two'
    assert.equal model[1], 'two'
    model.unshift 'three'
    assert.equal model[0], 'three'

  it 'remove one item', ->
    model.remove 'one'
    assert.equal model[1], 'two'
    assert.equal model.length, 2
    model.pop()
    assert.equal model[0], 'three'
    assert.equal model.length, 1
    model.shift 'three'
    assert.equal model.length, 0

  it 'add multiple items', ->
    model.push 'one', 'two', 'three'
    assert.equal model.toString(), 'one,two,three'

  it 'splice', ->
    model.splice 1,1, 'four'
    assert.equal model.toString(), 'one,four,three'

describe 'change event :', ->

  model = []

  beforeEach ->
    model = ['one', 'two', 'three'].model()

  it 'on add item', ->
    fired = no
    model.on 'change', (mod) ->
      fired = yes
      assert.strictEqual mod, model
    model.add 'four'
    assert.ok fired

  it 'on remove item', ->
    fired = no
    model.on 'change', (mod) ->
      fired = yes
      assert.strictEqual mod, model
    model.remove 'four'
    assert.notOk fired
    model.remove 'three'
    assert.ok fired

  it 'on add and remove and the same time', ->
    fired = 0
    model.on 'change', (mod) ->
      fired = 1
      assert.strictEqual mod, model
    model.splice 1, 1, 'four'
    assert.equal fired, 1

  it 'assignment', ->
    fired = no
    model.on 'change', (mod) ->
      fired = yes
      assert.strictEqual mod, model
    model[1] = 'three'
    assert.ok fired


describe 'add/remove events :', ->

  model = []

  beforeEach ->
    model = ['one', 'two', 'three'].model()

  it 'on add item', ->
    fired = no
    model.on 'add', (val, pos, mod) ->
      fired = yes
      assert.equal val, 'four'
      assert.equal pos, 3
      assert.strictEqual mod, model
    model.add 'four'
    assert.ok fired

  it 'on remove item', ->
    fired = no
    model.on 'remove', (val, pos, mod) ->
      fired = yes
      assert.equal val, 'three'
      assert.equal pos, 2
      assert.strictEqual mod, model
    model.remove 'four'
    assert.notOk fired
    model.remove 'three'
    assert.ok fired

  it 'on add and remove and the same time', ->
    fired = 0
    model.on 'add', (val, pos, mod) ->
      fired++
      assert.equal val, 'four'
      assert.equal pos, 1
      assert.strictEqual mod, model
    model.on 'remove', (val, pos, mod) ->
      fired++
      assert.equal val, 'two'
      assert.equal pos, 1
      assert.strictEqual mod, model
    model.splice 1, 1, 'four'
    assert.equal fired, 2

  it 'assignment', ->
    fired = 0
    model.on 'add', (val, pos, mod) ->
      fired++
      assert.equal val, 'four'
      assert.equal pos, 1
      assert.strictEqual mod, model
    model.on 'remove', (val, pos, mod) ->
      fired++
      assert.equal val, 'two'
      assert.equal pos, 1
      assert.strictEqual mod, model
    model[1] = 'four'
    assert.equal fired, 2

  it 'change on add', ->
    fired = 0
    model.on 'add', (val, pos, mod) ->
      mod[pos] += 'four'
      fired++
    model[1] = 'four'
    model.add 'four'
    assert.equal fired, 2
    assert.equal model.toString(), 'one,fourfour,three,fourfour'

describe 'setter and getter :', ->

  model = []

  beforeEach ->
    model = ['one', 'two', 'three'].model()

  it 'on get item', ->
    model.get (val, pos) ->
      assert.equal pos, 1
      val + 'four'
    assert.equal model[1], 'twofour'
    model.get (val) ->
      val + 'four'
    assert.deepEqual model.slice(), ['onefour', 'twofour', 'threefour']

  it 'on set item', ->
    fired = no
    model.set (val, pos) ->
      fired = yes
    model[1] = 'four'
    assert.ok fired
    assert.equal model.toString(), 'one,four,three'

describe 'tests from real life :', ->

  it 'prevent addition of objects with wrong type', ->
    model = [].model()
    model.on 'add', (val, pos, mod) ->
      if (typeof val) isnt 'number'
        mod.splice pos, 1
    model.push 42
    assert.equal model.toString(), '42'
    model.push '24'
    assert.equal model.toString(), '42'
    model.push 24
    assert.equal model.toString(), '42,24'
    model[1] = '24'
    assert.equal model.toString(), '42'

  it 'sqr test', ->
    model = [1,2,3].model()
    model.get (val) -> val * val
    assert.equal model.slice().toString(), '1,4,9'
    assert.equal model[2], 9