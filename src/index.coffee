yaml_front = require 'yaml-front-matter'
highlight = require 'highlight.js'
marked = require 'marked'
pug = require 'pug'
_assign = require 'lodash/assign'


module.exports = class ClumsyBrunch
  brunchPlugin: yes
  type: 'template'
  extension: 'md'

  staticTargetExtension: 'html'

  marked:
    gfm: yes

  pug:
    pretty: yes

  constructor: (conf) ->
    @_marked_ = marked
    @_initMarkdown_()

  _initMarkdown_: ->
    @marked.highlight = (code, lang) ->
      if lang in highlight.listLanguages()
        highlight.highlight(lang, code).value
      else
        highlight.highlightAuto(code).value
    @_marked_.setOptions(@marked)

  grabFrontAndContent: (input) ->
    data = yaml_front.loadFront input, 'content'
    data.content = @compileMarkdown data.content
    data

  compileMarkdown: (input) ->
    @_marked_ input

  applyTemplate: (template, data) ->
    opts = _assign data, @pug
    pug.render template, opts
