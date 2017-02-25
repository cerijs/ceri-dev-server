ceri = require "../src/createView.coffee"
window.customElements.define "custom-element", ceri
  props:
    test:
      type: String
  mixins: [
    require("ce/props")
  ]
module.exports = ceri
  structure: template 1, """
    <custom-element id="test" disabled=2 :test=test @click=onClick #text=text>
    <div><slot></slot></div>
    </custom-element>
  """
  methods:
    onClick: -> console.log "clicked"
  data: ->
    test: "testContent"
