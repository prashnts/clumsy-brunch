_set = require 'lodash/set'
path = require 'path'


class Tree
  constructor: (conf) ->
    @tree = {}

  insert: (node) ->
    {dir, name, base, ext} = path.parse node

    tree_path = "#{dir.replace /\//g, '.'}.#{base.replace /\./g, '_'}"
    node_prop = [name, ext]

    _set @tree, tree_path, node_prop

  clear: ->
    @tree = {}

module.exports = Tree
