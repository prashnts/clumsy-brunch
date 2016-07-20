{assert, expect} = require 'chai'

Tree = require '../src/tree'


describe 'Tree', ->
  it 'should be an object', ->
    expect(new Tree).to.be.an('object')

  tree = new Tree

  beforeEach 'clear the tree', -> tree.clear()

  describe '#insert', ->
    it 'adds entry in tree', ->
      tree.insert 'a/b/c.html'
      expect(tree.tree).to.deep.equal a: b: c_html: ['c', '.html']

    it 'appends entries together', ->
      tree.insert 'a/b.html'
      tree.insert 'a/c.html'
      tree.insert 'a/b/d.html'

      expect(tree.tree).to.deep.equal
        a:
          b: d_html: ['d', '.html']
          b_html: ['b', '.html']
          c_html: ['c', '.html']
