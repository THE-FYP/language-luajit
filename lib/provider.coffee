fs = require 'fs'
path = require 'path'

module.exports =
  selector: '.source.lua'
  disableForSelector: '.source.lua .comment, .source.lua .string'
  inclusionPriority: 1
  excludeLowerPriority: true

  getSuggestions: ({editor, bufferPosition, scopeDescriptor, prefix, activatedManually}) ->
    prefix = @getPrefix(editor, bufferPosition)
    return null if not prefix? and not activatedManually
    return @findSuggestions(@completions.words, '') if not prefix?
    return null if prefix.delim is '.' and not @completions.libraries[prefix.left]?
    return @findSuggestions(@completions.libraries[prefix.left], prefix.right) if prefix.delim is '.'
    return @findSuggestions(@completions.members, prefix.right) if prefix.delim is ':'
    return @findSuggestions(@completions.words, prefix.left, ["function"])

  findSuggestions: (completions, prefix, fullmatchonly = null) ->
    prefix ?= ''
    suggestions = []
    for item in completions
      if fullmatchonly isnt null and item.text == prefix
        suggestions.push(@buildSuggestion(item)) if item.type in fullmatchonly
      else if @compareStrings(item.text, prefix)
        suggestions.push(@buildSuggestion(item))
    suggestions

  buildSuggestion: (item) ->
    suggestion =
      text: item.text
      snippet: item.snippet
      displayText: item.displayText
      type: item.type
      leftLabel: item.leftLabel
      rightLabel: item.rightLabel

  loadCompletions: ->
    @completions = {}
    fs.readFile path.resolve(__dirname, '..', './data/autocompletion.json'), (error, data) =>
      @completions = JSON.parse(data) unless error?
      return

  getPrefix: (editor, bufferPosition) ->
    regex = /([a-zA-Z_][\w]*)(\.|:)?([a-zA-Z_][\w]*)?$/
    line = editor.getTextInRange([[bufferPosition.row, 0], bufferPosition])
    res = line.match(regex)
    left: res[1], delim: res[2], right: res[3] if res?

  compareStrings: (str, substr) ->
    return false if substr.length > str.length
    substr == str.substring(0, substr.length)
