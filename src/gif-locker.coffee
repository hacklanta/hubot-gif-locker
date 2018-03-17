# Description:
#   Store and retrieve your favorite gif urls
#
# Dependencies:
#   Nope
#
# Configuration:
#   Nope
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

GIF_LOCKER = 'gifLocker'

module.exports = (robot) ->
  withGifs = (callback) ->
    gifLocker = robot.brain.get(GIF_LOCKER) || {}
    gifs = gifLocker.gifs || {}

    callback(gifs)

  updatingGifs = (callback) ->
    gifLocker = robot.brain.get(GIF_LOCKER) || {}
    gifs = gifLocker.gifs || {}

    updatedGifs = callback(gifs)

    # Make sure no one accidentally overwrites the gifs with something totally
    # busted.
    if updatedGifs? && typeof updatedGifs == 'object'
      gifLocker.gifs = updatedGifs
      robot.brain.set('gifLocker', gifLocker)

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
    migrateURLData ->
  , 4 * 1000

  storeGif = (msg) ->
    gifName = msg.match[1].trim().toLowerCase()
    gifUrl = msg.match[2].trim()

    updatingGifs (gifs) ->
      gifs[gifName] ||= []
      gifs[gifName].push gifUrl

      message =
        switch gifs[gifName].length
          when 1
            "one entry for that name"
          else
            "#{gifs[gifName].length} entries for that name"

      msg.send "#{gifName}. Got it; #{message}."

      gifs

  showGif = (msg, showNoGifMessage = true) ->
    gifName = msg.match[1].trim().toLowerCase()

    withGifs (gifs) ->
      gifSet = gifs[gifName] || []

      if gifSet.length > 0
        gifUrl = gifSet[Math.floor(Math.random()*gifSet.length)]
        msg.send gifUrl
      else
        if showNoGifMessage
          msg.send "Did not find any cool gifs for #{gifName}. You should add some!"

  listGifs = (msg) ->
    gifName = msg.match[1].trim().toLowerCase()

    withGifs (gifs) ->
      gifSet = gifs[gifName] || []

      msg.send gifSet.join(", ")

  listAllGifs = (msg) ->
    withGifs (gifs) ->
      names = Object.keys gifs

      names = names.sort().toString().replace(/,/g, "\n")

      msg.send names

  removeGifsByName = (msg) ->
    gifName = msg.match[1].trim().toLowerCase()

    updatingGifs (gifs) ->
      delete gifs[gifName]
    
      msg.send "Removed all URLs for #{gifName}."

      gifs

  removeGifsByNameUrl = (msg) ->
    gifName = msg.match[1].trim().toLowerCase()
    gifUrl = msg.match[2].trim()

    updatingGifs (gifs) ->
      namedGifs = gifs[gifName]
      namedGifs = namedGifs.filter((_) -> _ != gifUrl)

      message =
        if namedGifs.length == 0
          delete gifs[gifName]
          "no URLs left for that name"
        else
          gifs[gifName] = namedGifs
          switch namedGifs.length
            when 1
              "1 URL left for that name"
            else
              "#{namedGifs.length} URLs left for that name"

      msg.send "Removed #{gifUrl} from #{gifName}; #{message}."

      gifs

  robot.respond /store (.+) (.+)/i, (msg) ->
    storeGif(msg)

  robot.respond /gif (.+)/i, (msg) ->
    showGif(msg)

  robot.hear ///^(?!#{robot.name})(.+)\.gif$///i, (msg) ->
    showGif(msg, false)

  robot.respond /list gifs (.+)/i, (msg) ->
    listGifs(msg)

  robot.respond /list gifs$/i, (msg) ->
    listAllGifs(msg)

  robot.respond /remove all (.+)/i, (msg) ->
    removeGifsByName(msg)

  robot.respond /remove gif (.+) (.+)/i, (msg) ->
    removeGifsByNameUrl(msg)
