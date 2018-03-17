Hubot Gif Locker
============

Hubot script for storing and retrieving gif urls.

* `{gif-name}.gif` - No hubot prefix, displays a random gif url from given name.
* `hubot gif {gif-name}` - Display random gif url from given name.
* `hubot (store|add) {gif-name} {gif-url}` - Store gif url with given name.
* `hubot alias {gif-name} {other-gif-name}` - Store gif-name so that it will always point to the gifs in other-gif-name.
* `hubot remove alias {gif-name}` - Removes gif-name as an alias.
* `hubot remove all {gif-name}` - Remove all gifs with given name.
* `hubot remove gif {gif-name} {gif-url}` - Remove specific gif url with given name.
* `hubot list gifs` - Display all gif names.
* `hubot list gifs {gif-name}` - Display gif urls from given name.
