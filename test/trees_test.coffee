{assert, expect} = require 'chai'

Tree = require '../src/tree'


describe 'Tree', ->
  it 'should be an object', ->
    expect(new Tree).to.be.an('object')

  tree = new Tree

  beforeEach 'clear the tree', -> tree.clear()

  describe '#insert', ->
    it 'adds entries with valid props', ->
      tree.insert 'foo'
      expect(tree.children().foo.isFile()).to.be.true

    it 'adds entry in tree', ->
      tree.insert 'foo/index.html'
      expect(tree.children().foo.children()['index.html'].isFile()).to.be.true

    it 'adds entry with props in tree', ->
      tree.insert 'foo/bar', 'banana!'
      expect(tree.children().foo.children().bar.content()).to.equal('banana!')

    it 'appends entries together', ->
      tree.insert 'foo/bar.html'
      tree.insert 'baz.html'
      expect(tree.children().foo.isDir()).to.be.true
      expect(tree.children()['baz.html'].isFile()).to.be.true

    it 'can add any value to files', ->
      tree.insert 'bar', title: 'yello!'
      expect(tree.children().bar.content().title).to.equal('yello!')

    it 'throws errors when children is expected on files', ->
      tree.insert 'bar'
      expect(-> tree.children().bar.children()).to.throw(TypeError)

  describe '#isRoot', ->
    it 'assumes self to be root if no parent found', ->
      expect(tree.isRoot()).to.be.true

    it 'knows self to be a children if parent exists', ->
      tree.insert 'baz'
      expect(tree.children().baz.isRoot()).to.be.false

  describe '#parent', ->
    it 'knows parent object', ->
      tree.insert 'baz'
      expect(tree.children().baz.parent.isRoot())

  describe '#url', ->
    it 'gets root url', ->
      expect(tree.url()).to.equal('')

    it 'gets children url', ->
      tree.insert 'baz'
      expect(tree.children().baz.url()).to.equal('baz')
      tree.insert 'foo/bar/index.html'
      expect(tree.children().foo.children().bar.children()['index.html'].url())
          .to.equal('foo/bar')
      tree.insert 'foo/bar/baz.html'
      expect(tree.children().foo.children().bar.children()['baz.html'].url())
          .to.equal('foo/bar/baz.html')
      expect(tree.children().foo.children().bar.url()).to.equal('foo/bar')

  describe '#content', ->
    it 'throws error when content is called on a dir', ->
      tree.insert 'baz'
      expect(-> tree.content()).to.throw(TypeError)

  describe '#index', ->
    it 'gets flat file tree', ->
      tree.insert 'foo/bar'
      tree.insert 'foo/baz/bax'
      tree.insert 'baz/bax'

      expect(tree.index())
          .to.deep.equal([
              ['foo/bar', true],
              ['foo/baz/bax', true],
              ['baz/bax', true]])
      expect(tree.children().foo.children().baz.index())
          .to.deep.equal([['foo/baz/bax', true]])
