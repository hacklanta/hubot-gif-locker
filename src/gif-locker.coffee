# Description:
#   Store and retrieve your favorite gif urls
#
# Dependencies:
#   "Underscore": "1.8.3"
#
# Configuration:
#   Nope
#
# Commands:
#   hubot gif {gif-name} - Display random gif url from given name.
#   <gif-name>.gif - Display random gif url from given name. Will not show error message if no gif found.
#   hubot store {gif-name} {gif-url} - Store gif url with given name.
#   hubot remove all {gif-name} - Remove all gifs with given name.
#   hubot remove gif {gif-name} {gif-url} - Remove specific gif url with given name.
#   hubot list gifs {gif-name} - Display gif urls from given name.
#   hubot list gifs - Display gif names stored.
# 
# Author: 
#   @riveramj

_ = require 'underscore'

module.exports = (robot) ->

  migrateURLData = (gifSet) ->
    gifLocker = robot.brain.get('gifLocker')
    migrated = gifLocker?.migrated || false

    if !migrated
      allGifs = gifLocker?.gifs || {}
      uniqueGifNames = []
      newGifs = {}
    
      for gif in allGifs
        name = gif.name.toLowerCase()
        gifSet = allGifs.filter (gif) -> gif.name.toLowerCase() == name
        for gif in gifSet
          newGifs[name] ||= []
          if newGifs[name].indexOf(gif.url) == -1
            newGifs[name].push gif.url

      gifLocker?.gifs = newGifs
      gifLocker?.migrated = true
    
      robot.brain.set 'gifLocker', gifLocker

  setTimeout ->
    #migrateURLData ->
  , 4 * 1000
  
  storeGif = (msg) ->
    name = msg.match[1].trim().toLowerCase()
    url = msg.match[2].trim()

    gifLocker = robot.brain.get('gifLocker') || {}
    gifLocker.gifs ||= []

    possibleGif = _.findWhere gifLocker.gifs, {name: name}

    if possibleGif?
      possibleGif.url.push url
    else
      gifLocker.gifs.push {name: name, url: [url]}

    robot.brain.set 'gifLocker', gifLocker

    msg.send "#{name}. Got it."

  showGif = (msg, showNoGifMessage = true) ->

    name = msg.match[1].trim().toLowerCase()

    gifLocker = robot.brain.get('gifLocker') || {}
    gifLocker.gifs ||= []

    possibleGif = _.findWhere(gifLocker.gifs, name: name)

    gif = if possibleGif?
      possibleGif
    else
      _.filter gifLocker.gifs, (maybeGif) -> _.contains maybeGif.alias, name
    
    urls = gif[0]?.url || []

    if urls.length > 0
      msg.send urls[Math.floor(Math.random() * urls.length)]
    else
      if showNoGifMessage
        msg.send "Did not find any cool gifs for #{name}. You should add some! Or create an alias!"

  listGifUrls = (msg) ->
    name = msg.match[1].trim().toLowerCase()

    gifLocker = robot.brain.get('gifLocker') || {}
    gifLocker.gifs ||= []

    possibleGif = _.findWhere gifLocker.gifs, name: name

    gif =
      if possibleGif?.url.length > 0
        possibleGif
      else
        (_.filter gifLocker.gifs, (maybeGif) -> _.contains maybeGif.alias, name)?[0]

    msg.send JSON.stringify(gif?.url)

  listAllGifs = (msg) ->
    gifLocker = robot.brain.get('gifLocker') || {}
    gifLocker.gifs || = []

    names = _.pluck gifLocker.gifs, 'name'
    aliases = _.pluck gifLocker.gifs, 'alias'

    gifs = names.concat aliases

    names = gifs.sort().toString().replace(/,/g, "\n")

    msg.send names

  removeGifsByName = (msg) ->
    name = msg.match[1].trim().toLowerCase()

    gifLocker = robot.brain.get('gifLocker') || {}
    gifLocker.gifs ||= []

    gifSet = _.reject gifLocker.gifs, (gif) -> gif.name == name
    
    gifLocker.gifs = gifSet

    robot.brain.set 'gifLocker', gifLocker
    
    msg.send "Removed #{name}."

  removeGifsByNameUrl = (msg) ->
    name = msg.match[1].trim().toLowerCase()
    url = msg.match[2].trim()

    gifLocker = robot.brain.get('gifLocker') || {}
    gifLocker.gifs ||= []
    gif = _.findWhere gifLocker.gifs, name: name
    updatedUrls = _.without gif.url, url

    _.extend gif, url: updatedUrls

    robot.brain.set 'gifLocker', gifLocker
    
    msg.send "Removed #{url} from #{name}."

  aliasGif = (msg) ->
    alias = msg.match[1].trim().toLowerCase()
    name = msg.match[2].trim().toLowerCase()

    gifLocker = robot.brain.get('gifLocker') || {}
    gifLocker.gifs ||= []

    possibleAlias = _.filter gifLocker.gifs, (maybeAlias) -> _.contains maybeAlias.alias, alias

    gif = _.findWhere(gifLocker.gifs, {name: name})

    if possibleAlias.length > 0
      msg.send "#{alias} already exists. Links to #{possibleAlias[0].name}."
    else
      if gif.alias?
        gif.alias.push alias
      else
      _.extend gif, {alias: [alias]}

      robot.brain.set 'gifLocker', gifLocker

      msg.send "#{name} aliased to #{alias}. Got it."

  renameGif = (msg) ->
    oldName = msg.match[1].trim().toLowerCase()
    newName = msg.match[2].trim().toLowerCase()

    gifLocker = robot.brain.get('gifLocker') || {}
    gifLocker.gifs ||= []
    
    gif = _.findWhere gifLocker.gifs, {name: oldName}
    _.extend gif, name: newName
    
    robot.brain.set 'gifLocker', gifLocker

    msg.send "Renamed #{oldName} to #{newName}"
  
  removeAlias = (msg) ->
    alias = msg.match[1].trim().toLowerCase()

    gifLocker = robot.brain.get('gifLocker') || {}
    gifLocker.gifs ||= []

    gif = (_.filter gifLocker.gifs, (maybeGif) -> _.contains maybeGif.alias, alias)?[0]
    if gif?.alias?.length > 0
      updatedAlias = _.reject gif.alias, (possibleAlias) -> possibleAlias == alias
    
      _.extend gif, alias: updatedAlias
  
      robot.brain.set 'gifLocker', gifLocker
      msg.send "Removed alias #{alias}."
    else
      msg.send "alias '#{alias}' not found."

  
  robot.respond /store (.+) (.+)/i, (msg) ->
    storeGif msg

  robot.respond /gif (.+)/i, (msg) ->
    showGif msg

  robot.hear ///^(?!#{robot.name})(.+)\.gif$///i, (msg) ->
    showGif msg, false

  robot.respond /list gifs (.+)/i, (msg) ->
    listGifUrls msg

  robot.respond /list gifs$/i, (msg) ->
    listAllGifs msg

  robot.respond /remove all (.+)/i, (msg) ->
    removeGifsByName msg

  robot.respond /remove gif (.+) (.+)/i, (msg) ->
    removeGifsByNameUrl msg

  robot.respond /alias gif (.+) to (.+)/i, (msg) ->
    aliasGif msg

  robot.respond /remove alias (.+)/i, (msg) ->
    removeAlias msg

  robot.respond /(?:rename|move|mv) gif (.+) to (.+)/i, (msg) ->
    renameGif msg
