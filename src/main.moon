import random from love.math
import tileSize from require "constants"
w, h = love.graphics.getDimensions!
screen = { w: math.floor(w/tileSize), h: math.floor(h/tileSize)}

debug = true
map = true

Player = require "Player"
player = Player!

World = require "World"
world = World!

time, step = 0, 1/30
love.update = (dt) ->
  time += dt
  if time >= step
    time -= step
    player\update step

love.draw = ->
  x, y = player\tile!
  screenX, screenY = 0, 0
  xOffset, yOffset = player\offset!
  for x = x - screen.w/2, x + screen.w/2
    for y = y - screen.h/2, y + screen.h/2
      tile = world\get x, y
      if tile
        love.graphics.setColor tile
      else
        love.graphics.setColor 0, 0, 0, 1
      love.graphics.rectangle "fill", screenX * tileSize - xOffset, screenY * tileSize - yOffset, tileSize, tileSize
      screenY += 1
    screenY = 0
    screenX += 1
  if debug
    love.graphics.setColor 1, 0, 0, 1
    love.graphics.circle "line", w/2, h/2, 5
    t = world\get player\tile!
    love.graphics.setColor 0, 0, 0, 1
    love.graphics.rectangle "fill", 0, 0, w, 16
    love.graphics.setColor 1, 1, 1, 1
    love.graphics.print t[5] or "", 1, 1
  if map
    mapResolution = 14
    x, y = player\tile!
    screenX, screenY = 0, 0
    for x = x - 50 * mapResolution, x + 49 * mapResolution, mapResolution
      for y = y - 50 * mapResolution, y + 49 * mapResolution, mapResolution
        if tile = world\get x, y
          love.graphics.setColor tile
        else
          love.graphics.setColor 0, 0, 0, 1
        love.graphics.points screenX, screenY
        screenY += 1
      screenY = 0
      screenX += 1

love.keypressed = (key) ->
  love.event.quit! if key == "escape"

  if key == "="
    player.speed *= 5
  if key == "-"
    player.speed /= 5

  if key == "r"
    world = World!
