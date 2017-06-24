describe "ceri-dev-server", ->
  it "should have a navigation", ->
    browser.url "/"
    expect("li").to.have.count 2
    expect("body").to.have.text "/test\n/test2"
  it "should work", ->
    browser.url "/#/test"
    expect("body").to.have.text "text"