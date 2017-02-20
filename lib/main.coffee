provider = require './provider'

module.exports =
  config:
    onlyKeywords:
      type: 'boolean'
      default: false
      title: 'Only Keywords Autocompletion'
      description: 'Disable all suggestions except for Lua keywords.'

  activate: -> provider.loadCompletions()
  provide: -> provider
