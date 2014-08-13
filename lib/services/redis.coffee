###
YOI
@description  Easy (but powerful) NodeJS Server
@author       Javi Jimenez Villar <javi@tapquo.org> || @soyjavi

@namespace    lib/services/redis
###
"use strict"

redis = require "redis"
Hope  = require "hope"

Redis =

  open: (@host, @port, password) ->
    promise = new Hope.Promise()
    @client = redis.createClient @port, @host
    @client.auth password if password?
    @client.on "error", (error) ->
      console.log "⚑".red, "REDIS".underline.red, "error connecting: #{error}"
      promise.done error, null
    @client.on "connect", =>
      console.log "✓".red, "REDIS".underline.red, "listening at", "#{@host}:#{@port}".underline.red
      promise.done null, true
    promise

  close: ->
    console.log "▣".red, "REDIS/#{@host}:#{@port}".underline.red, "closed connection"
    do @client.quit

  set: (key, value) -> @client.SET String(key), value

  json: (key, value) -> @client.SET String(key), JSON.stringify value

  incr: (key, callback) -> @client.INCR String(key), callback

  decr: (key, callback) -> @client.DECR String(key), callback

  expire: (key, time) -> @client.EXPIRE String(key), time

  remove: (key) -> @client.DEL String(key)

  hgetall: (key, callback) -> @client.HGETALL String(key), callback

  hdel: (key, field) -> @client.hdel String(key), field

  hincrby: (key, field, increment) -> @client.HINCRBY String(key), field, increment

  run: (args...) ->
    @client[args[0]].apply @client, args.slice(1)

  multi: (actions, callback) ->
    @client.multi(actions).exec callback

  get: (key, callback) ->
    @client.GET key, (error, result) ->
      result = JSON.parse result if result?
      callback error, result

  cache: (key, value, expire, json=true) ->
    if json then @json key, value else @set key, value
    @client.EXPIRE String(key), expire

module.exports = Redis
