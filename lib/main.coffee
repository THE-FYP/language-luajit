provider = require './provider'

module.exports =
  activate: -> provider.loadCompletions()
  provide: -> provider
