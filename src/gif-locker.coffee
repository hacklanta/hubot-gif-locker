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


module.exports = (robot) ->

  storeGif = (msg) ->
    gifName = msg.match[1].trim()
    gifUrl = msg.match[2].trim()

    gifLocker = robot.brain.get('gifLocker') || {}
    gifLocker.gifs ||= []
    gifLocker.gifs.push { name: gifName, url: gifUrl }

    robot.brain.set 'gifLocker', gifLocker

    msg.send "#{gifName}. Got it."

  showGif = (msg, showNoGifMessage) ->

    gifName = msg.match[1].trim()

    gifLocker = robot.brain.get('gifLocker')
    gifSet = gifLocker?.gifs?.filter (gif) -> gif.name.toLowerCase() == gifName.toLowerCase()

    if gifSet?.length > 0
      gifUrl = gifSet[Math.floor(Math.random()*gifSet.length)].url
      msg.send gifUrl
    else
      if showNoGifMessage
        msg.send "Did not find any cool gifs for #{gifName}. You should add some!"

  listGifs = (msg) ->
    gifName = msg.match[1].trim()

    gifLocker = robot.brain.get('gifLocker')
    gifSet = gifLocker?.gifs?.filter (gif) -> gif.name.toLowerCase() == gifName.toLowerCase()

    msg.send JSON.stringify(gifSet)

  listAllGifs = (msg) ->
    gifLocker = robot.brain.get('gifLocker')
    gifSet = gifLocker?.gifs

    names = []
    
    for gif in gifSet
      if (names.indexOf(gif.name) == -1)
        names.push gif.name

    names = names.sort().toString().replace(/,/g, "\n")

    msg.send names

  removeGifsByName = (msg) ->
    gifName = msg.match[1].trim()

    gifLocker = robot.brain.get('gifLocker')
    gifSet = gifLocker?.gifs?.filter (gif) -> gif.name.toLowerCase() != gifName.toLowerCase()
    gifLocker.gifs = gifSet

    robot.brain.set 'gifLocker', gifLocker
    
    msg.send "Removed #{gifName}."

  removeGifsByNameUrl = (msg) ->
    gifName = msg.match[1].trim()
    gifUrl = msg.match[2].trim()

    gifLocker = robot.brain.get('gifLocker')
    gifSet = gifLocker?.gifs?.filter (gif) -> !(gif.name.toLowerCase() == gifName.toLowerCase() && gif.url == gifUrl)
    gifLocker.gifs = gifSet

    robot.brain.set 'gifLocker', gifLocker
    
    msg.send "Removed #{gifUrl} from #{gifName}."
  

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
