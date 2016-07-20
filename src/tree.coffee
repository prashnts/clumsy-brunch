_compact = require 'lodash/compact'
path = require 'path'


class Tree
  constructor: (props = {}) ->
    dirTree = _dir: yes
    {@parent, @name, @tree = dirTree} = props

  insert: (node, val) ->
    [root, child...] = node.split(path.sep)

    if child.length is 0
      @tree[root] = new Tree
        parent: @
        name: root
        tree: if val? then val else root
    else
      child_node = child.join(path.sep)

      unless @tree[root]? then @tree[root] = new Tree parent: @, name: root
      @tree[root].insert child_node

  clear: ->
    @tree = _dir: yes

  children: ->
    if @isFile() then throw new TypeError 'not a directory'
    @tree

  content: ->
    unless @isFile() then throw new TypeError 'is a directory'
    @tree

  url: (omit_index = yes) ->
    base = if @parent then @parent.url()
    if @isFile()
      if omit_index and @tree is 'index.html'
        return base
    _compact([base, @name]).join '/'


  isFile: -> not @isDir()
  isDir: -> @tree._dir? is yes
  isRoot: -> not @parent?

module.exports = Tree
