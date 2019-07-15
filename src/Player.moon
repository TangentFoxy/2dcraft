import floor from math
import tileSize from require "constants"

class Player
  new: (@x=0, @y=0) =>
    @speed = 2500 -- 100
  update: (dt) =>
    if love.keyboard.isDown "w"
      @y -= @speed * dt
    if love.keyboard.isDown "a"
      @x -= @speed * dt
    if love.keyboard.isDown "s"
      @y += @speed * dt
    if love.keyboard.isDown "d"
      @x += @speed * dt
  tile: => return floor(@x/tileSize), floor(@y/tileSize)
  offset: => return @x % tileSize, @y % tileSize
