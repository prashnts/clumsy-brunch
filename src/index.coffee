yaml_front = require 'yaml-front-matter'
highlight = require 'highlight.js'


module.exports = class ClumsyBrunch
  brunchPlugin: yes
  type: 'template'
  extension: 'md'

  staticTargetExtension: 'html'


  constructor: (conf) ->
    null
