startupRouter = ->
  clearSlashes = (path)  ->
    return path.toString().replace(/\/$/, '').replace(/^\//, '')
  getFragment = ->
    match = window.location.href.match(/#(.*)$/)
    if match then return match[1] else return defaultRoute
  current = ''
  listen = ->
    frag = getFragment()
    if current != frag
      current = frag
      route()
      document.title = current + " - ceri-dev-server"
  setInterval listen, 50
  routes = {}
  view = null
  views = {}
  getRoutes()
  if Object.keys(routes).length == 1
    defaultRoute = Object.keys(routes)[0]
  else
    defaultRoute = "/"
  route = ->
    unless routes[current]?
      current = defaultRoute
      window.location.href = window.location.href.replace(/#(.*)$/, '') + '#' + defaultRoute
    document.body.removeChild(view) if view?
    if views[current]?
      view = views[current]
    else
      view = routes[current]
      name = "ce#{current.replace('/','-')}"
      window.customElements.define name, view
      view = document.createElement(name)
      views[current] = view
    document.body.appendChild(view)
  nav = document.createElement "ul"
  for routename, val of routes
    nav.innerHTML += "<li><a href='##{routename}'>#{routename}</a></li>"
  views["/"] = nav
  routes["/"] = true
  listen()
require("document-register-element/pony")(global,'force')
startupRouter()
# polyfillCE = ->
#   require.ensure([],((require) ->
#     require("document-register-element/pony")(global,'force')
#     startupRouter()
#   ),"cePoly")
# unless window.customElements?
#   polyfillCE()
# else
#   # always use polyfill to be ES5 compilant
#   # startupRouter()
#   polyfillCE()
