casper.on "remote.message", (e) -> console.log e
casper.test.begin "ceri-dev-server", 6, (test) ->
  casper.start "http://localhost:8080/"
  .then ->
    test.assertElementCount('ul', 1)
    test.assertElementCount('li', 2)
    test.assertTextExists("/test","found")
    test.assertTextExists("/test2","found")
  .thenOpen "http://localhost:8080/#/test"
  .wait 100, ->
    test.assertTextExists("text","found")
  .thenOpen "http://localhost:8080/#/test2"
  .wait 100, ->
    test.assertTextExists("test2","found")
  .run ->
    test.done()
