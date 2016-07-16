{assert} = require 'chai'

ClumsyBrunch = require '../src/index'

describe 'ClumsyBrunch', ->
  cb = new ClumsyBrunch

  it 'should be a brunch plugin', ->
    assert.isTrue cb.brunchPlugin
  it 'should be typed as "template"', ->
    assert.equal 'template', cb.type

  describe '#grabFrontAndContent', ->
    it 'should return an object', ->
      assert.isObject cb.grabFrontAndContent ''
