_compact = require 'lodash/compact'
path = require 'path'


class Tree
  constructor: (parent, name, init = {}) ->
    @parent = parent
    @name = name
    @tree = init

  insert: (node) ->
    [root, child...] = node.split(path.sep)

    if child.length is 0
      @tree[root] = new Tree(@, root, root)
    else
      child_node = child.join(path.sep)

      unless @tree[root]? then @tree[root] = new Tree(@, root)
      @tree[root].insert child_node

  clear: ->
    @tree = {}

  children: ->
    @tree

  url: (omit_index = yes) ->
    base = if @parent then @parent.url()
    if @isFile()
      if omit_index and @tree is 'index.html'
        return base
    _compact([base, @name]).join '/'


  isFile: -> typeof @tree is 'string'
  isDir: -> not @isFile()
  isRoot: -> not @parent?

module.exports = Tree
