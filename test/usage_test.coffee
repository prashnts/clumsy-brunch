fs = require 'fs'
{assert, expect} = require 'chai'

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

    it 'extracts the yaml frontmatter', ->
      fldata = fs.readFileSync 'test/data/sample_trivial.md', 'utf-8'
      result = cb.grabFrontAndContent fldata
      assert.equal 'bar', result.foo
      assert.equal 10, result.baz
      assert.deepEqual ['bah', 'humbug'], result.bok

      expect(result.content).to.be.a('string').and.have.length.above(10)
