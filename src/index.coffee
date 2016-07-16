yaml_front = require 'yaml-front-matter'
highlight = require 'highlight.js'
marked = require 'marked'


module.exports = class ClumsyBrunch
  brunchPlugin: yes
  type: 'template'
  extension: 'md'

  staticTargetExtension: 'html'


  constructor: (conf) ->
    @marked = marked
    @_initMarkdown_()

  _initMarkdown_: ->
    options =
      highlight: (code, lang) ->
        if lang in highlight.listLanguages()
          highlight.highlight(lang, code).value
        else
          highlight.highlightAuto(code).value
    @marked.setOptions(options)


  grabFrontAndContent: (input) ->
    yaml_front.loadFront input, 'content'

  compileMarkdown: (input) ->
    @marked input

  applyTemplates: (input) ->
