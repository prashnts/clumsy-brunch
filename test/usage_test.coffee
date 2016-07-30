fs = require 'fs'
{assert, expect} = require 'chai'

ClumsyBrunch = require '../src/index'


describe 'ClumsyBrunch', ->
  cb = new ClumsyBrunch
  fldata = fs.readFileSync 'test/data/sample_trivial.md', 'utf-8'

  it 'should be a brunch plugin', ->
    assert.isTrue cb.brunchPlugin
  it 'should be typed as "template"', ->
    assert.equal 'template', cb.type

  describe '#grabFrontAndContent', ->
    it 'should return an object', ->
      assert.isObject cb.grabFrontAndContent ''

    it 'extracts the yaml frontmatter', ->
      result = cb.grabFrontAndContent fldata
      assert.equal 'bar', result.foo
      assert.equal 10, result.baz
      assert.deepEqual ['bah', 'humbug'], result.bok

      expect(result.content).to.be.a('string').and.have.length.above(10)

  describe '#compileMarkdown', ->
    it 'should return string', ->
      expect(cb.compileMarkdown('')).to.be.a('string')

    it 'should produce correct html', ->
      input = 'Hey *kids*, let\'s have ice creams!'
      output = '<p>Hey <em>kids</em>, let&#39;s have ice creams!</p>\n'
      expect(cb.compileMarkdown(input)).to.equal(output)

    it 'should apply syntax highlighting', ->
      input = """
      Here's a beautiful Python Code for my love:
      ```Python
      data = [x**2 for x in range(len(100))]
      ```
      """
      #coffeelint: disable=max_line_length
      output = """
      <p>Here&#39;s a beautiful Python Code for my love:</p>
      <pre><code class="lang-Python">data = [x**<span class="hljs-number">2</span> <span class="hljs-keyword">for</span> x <span class="hljs-keyword">in</span> <span class="hljs-keyword">range</span>(len(<span class="hljs-number">100</span>))]
      </code></pre>\n
      """
      #coffeelint: enable=max_line_length
      expect(cb.compileMarkdown(input)).to.equal(output)

  describe '#applyTemplate', ->
    it 'should compile the jade file with frontmatter data', ->
      input_md = """
      ---
      title: Whoa, whoa
      dated: 10 July, 2016
      ---
      > You must forge your own path for it to mean anything.

      ```python
      class Path:
        @property
        def meaning(self):
          return 42
      ```
      """

      #coffeelint: disable=max_line_length
      output = """
      <!DOCTYPE html>
      <html>
        <head>
          <title>Whoa, whoa</title>
        </head>
        <body>
          <div><blockquote>
      <p>You must forge your own path for it to mean anything.</p>
      </blockquote>
      <pre><code class="lang-python"><span class="hljs-class"><span class="hljs-keyword">class</span> <span class="hljs-title">Path</span>:</span>
      <span class="hljs-meta">  @property</span>
        <span class="hljs-function"><span class="hljs-keyword">def</span> <span class="hljs-title">meaning</span><span class="hljs-params">(self)</span>:</span>
          <span class="hljs-keyword">return</span> <span class="hljs-number">42</span>
      </code></pre>
      </div>
        </body>
      </html>
      """
      #coffeelint: enable=max_line_length
      jade_template = './test/data/layout.jade'

      data = cb.grabFrontAndContent input_md
      expect(cb.applyTemplate jade_template, data).to.equal output


describe 'ClumsyBrunch within Fixture', ->
  conf_file_data = fs.readFileSync 'test/data/sample.conf.json', 'utf-8'
  conf = JSON.parse conf_file_data
  sample_doc = fs.readFileSync 'test/data/sample_doc.md', 'utf-8'
  cb = new ClumsyBrunch conf

  describe '#_shouldProceed', ->
    it 'should only proceed for files within content directory', ->
      expect(cb._shouldProceed('app/content/doc.md')).to.be.true
      expect(cb._shouldProceed('app/somewhere/doc.md')).to.be.false
      expect(cb._shouldProceed('test/content/doc.md')).to.be.true
      expect(cb._shouldProceed('huh/somewhere/doc.md')).to.be.false

  describe '#_findDestination', ->
    file = path: 'app/content/doc.md', data: sample_doc
    payload = cb.grabFrontAndContent sample_doc

    it 'should return correct destination of payload', ->
      expect(cb._findDestination file, payload)
          .to.deep.equal
            dir: 'public/blog/2016/06/10/hello-world'
            name: 'index'
            path: 'public/blog/2016/06/10/hello-world/index.html'

  describe '#_ensureFields', ->
    it 'should be ok if `path` is explicitly provided', ->
      expect(cb._ensureFields path: 'foo').to.be.ok
    it 'should be ok if `title` and `date` are present', ->
      expect(cb._ensureFields title: 'foo', published: 'bar').to.be.o
    it 'should throw error in all other cases', ->
      expect(-> cb._ensureFields(foo: 'bar')).to.throw(Error)

  describe '#_ensureLayoutContentTransform', ->
