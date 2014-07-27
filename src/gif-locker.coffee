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
#   hubot store {gif-name} {gif-url} - Store gif url with given name.
#   hubot remove all {gif-name} - Remove all gifs with given name.
#   hubot remove gif {gif-name} {gif-url} - Remove specific gif url with given name.
#   hubot list gifs {gif-name} - Display gif urls from given name.
# 
# Author: 
#   hacklanta


module.exports = (robot) ->

  storeGif = (msg) ->
    gifName = msg.match[1].trim()
    gifUrl = msg.match[2].trim() 

    gifLocker = robot.brain.get('gifLocker') || {}
    gifLocker.gifs ||= []
    gifLocker.gifs.push { name: gifName, url: gifUrl }

    robot.brain.set 'gifLocker', gifLocker

    msg.send "#{gifName}. Got it."

  showGif = (msg) ->
    gifName = msg.match[1].trim()

    gifLocker = robot.brain.get('gifLocker')
    gifSet = gifLocker?.gifs?.filter (gif) -> gif.name == gifName
    gifUrl = gifSet[Math.floor(Math.random()*gifSet.length)].url

    msg.send gifUrl

  listGifs = (msg) ->
    gifName = msg.match[1].trim()

    gifLocker = robot.brain.get('gifLocker')
    gifSet = gifLocker?.gifs?.filter (gif) -> gif.name == gifName

    console.log JSON.stringify(gifSet) + " fooo"
    msg.send JSON.stringify(gifSet)

  removeGifsByName = (msg) ->
    gifName = msg.match[1].trim()

    gifLocker = robot.brain.get('gifLocker')
    gifSet = gifLocker?.gifs?.filter (gif) -> gif.name != gifName
    gifLocker.gifs = gifSet

    robot.brain.set 'gifLocker', gifLocker
    
    msg.send "Removed #{gifName}."

  removeGifsByNameUrl = (msg) ->
    gifName = msg.match[1].trim()
    gifUrl = msg.match[2].trim() 

    gifLocker = robot.brain.get('gifLocker')
    gifSet = gifLocker?.gifs?.filter (gif) -> !(gif.name == gifName && gif.url == gifUrl)
    gifLocker.gifs = gifSet

    robot.brain.set 'gifLocker', gifLocker
    
    msg.send "Removed #{gifUrl} from #{gifName}."
  

  robot.respond /store (.+) (.+)/i, (msg) ->
    storeGif(msg)

  robot.respond /gif (.+)/i, (msg) ->
    showGif(msg)
  
  robot.respond /list gifs (.+)/i, (msg) ->
    listGifs(msg)

  robot.respond /remove all (.+)/i, (msg) ->
    removeGifsByName(msg)

  robot.respond /remove gif (.+) (.+)/i, (msg) ->
    removeGifsByNameUrl(msg)
