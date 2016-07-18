_assign = require 'lodash/assign'
_find = require 'lodash/find'
_has = require 'lodash/has'
fs = require 'fs'
highlight = require 'highlight.js'
marked = require 'marked'
mkdirp = require 'mkdirp'
moment = require 'moment'
path = require 'path'
pug = require 'pug'
slug = require 'slug'
yaml_front = require 'yaml-front-matter'


module.exports = class ClumsyBrunch
  brunchPlugin: yes
  type: 'template'
  extension: 'md'
  outExtension: 'html'

  paths:
    layouts: 'layouts'
    content: 'content'
    public: 'public'
    root: 'blog'

  fields:
    title: 'title'
    date: 'published'

  wrapHTML: yes
  slugify: yes

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

    payload = @grabFrontAndContent file.data

    unless payload.path? or not _has(payload, [@fields.title, @fields.date])
      throw error: 'Required fields not found'

    if payload.layout?
      format_layout = (dir) => "#{dir}/#{@paths.layouts}/#{payload.layout}.jade"
      dir = _find @paths.watched, (dir) ->
        fs.statSync(format_layout(dir)).isFile()

      unless dir then throw error: 'Cannot locate layout'

      payload.content = @applyTemplate format_layout(dir), payload

    destination = do =>
      base_name = path.basename(file.path, ".#{@extension}")
      dir_name = "#{@paths.public}"
      if payload.path?
        dir_name += "/#{payload.path}"
      else
        slug_name = slug(payload[@fields.title], @slug)
        date_dirs = moment(payload[@fields.date]).format('Y/MM/DD')
        dir_name += "/#{@paths.root}/#{date_dirs}"

        if @wrapHTML
          dir_name += "/#{slug_name}"
          base_name = 'index'
        else
          base_name = slug_name

      return dir: dir_name, name: base_name

    mkdirp.sync destination.dir

    outfile = "#{destination.dir}/#{destination.name}.#{@outExtension}"

    fs.writeFileSync outfile, payload.content

