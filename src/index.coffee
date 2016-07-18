
yaml_front = require 'yaml-front-matter'
highlight = require 'highlight.js'
marked = require 'marked'
pug = require 'pug'
slug = require 'slug'
_assign = require 'lodash/assign'
mkdirp = require 'mkdirp'
fs = require 'fs'
moment = require 'moment'


module.exports = class ClumsyBrunch
  brunchPlugin: yes
  type: 'template'
  extension: 'md'

  paths:
    layouts: 'layouts'
    content: 'content'

  fields:
    title: 'title'
    date: 'published'
    category: 'category'

  wrap_html: yes
  slugify: yes
  categorize: yes

  marked:
    gfm: yes

  pug:
    pretty: yes

  slug:
    mode: 'rfc3986'

  constructor: (conf = {}) ->
    @_marked_ = marked
    @_initMarkdown_()
    @paths.public = conf.paths?.public
    @paths.watched = conf.paths?.watched

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
    pug.renderFile template, opts

  compile: (file) ->
    @processFile(file)
    Promise.resolve()

  processFile: (file) ->
    proceed = @paths.watched.reduce(
      (prev, curr) =>
        prev or file.path.startsWith("#{curr}/#{@paths.content}")
      no
    )
    unless proceed then return

    destination = null


    data = @grabFrontAndContent file.data
    title_slug = slug(data.title, @slug)
    dates = moment(data.published).format('Y/MM/DD')
    path = "#{@pub_path}/#{dates}/#{title_slug}"

    if data.layout?
      template_path = "#{@layout_root}/layouts/#{data.layout}.jade"
      data.content = @applyTemplate template_path, data

    mkdirp path, (er) ->
      fs.writeFile "#{path}/index.html", data.content, (er) ->
        console.log 'Done.'
