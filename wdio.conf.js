module.exports = {
  config: {
    framework: 'mocha',
    baseUrl: 'http://localhost:8080/',
    capabilities: [{
      browserName: 'chrome'
    }],
    services: ['selenium-standalone'],
    reporters: ['spec'],
    logLevel: 'debug',
    coloredLogs: true,
    before: function () {
      var chai = require('chai')
      var chaiWebdriver = require('chai-webdriverio').default
      chai.use(chaiWebdriver(browser))
      global.expect = chai.expect
      chai.should()
    },
    mochaOpts: {
      ui: 'bdd',
      compilers: ["coffee:coffee-script/register"]
    },
    specs: [
      "test/*.coffee"
    ]
  }
}