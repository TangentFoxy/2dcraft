import random, noise from love.math

-- biomes = love.image.newImageData "biomes4.png"
sands = love.image.newImageData "sands.png"
grass = love.image.newImageData "biomes4.png"

colors = {
  {0.92, {0.7, 0.7, 1, 1}}, -- ice (mountain)
  {0.68, {0, 1/3, 0, 1}},   -- grass (other)
  {0.65, {0.9, 0.8, 0, 1}}, -- shorelines (sand)
  {0, {0, 0, 0.7, 1}}       -- water (ocean / lakes / wells)
}

class World
  new: =>
    @map = {}
    @lacunarity = 4
    @persistance = 0.287
    @octaves = 4
    @scale = 0.00025 -- originally 0.00005 but that was too far out
    @offset = love.math.random!

  get: (x, y) =>
    map = @map
    unless map[x]
      map[x] = {}
    unless map[x][y]
      @generate x, y
    return map[x][y]

  generate: (x, y) =>
    unless @map[x]
      @map[x] = {}
    unless @map[x][y]
      value = 0
      range = 0
      for octave = 1, @octaves
        frequency = @lacunarity^octave * @scale
        amplitude = @persistance^octave
        range += amplitude
        value += amplitude * love.math.noise x * frequency + @offset, y * frequency + @offset
      value /= range
      for color in *colors
        if color[1] < value
          if color[1] == 0.65 -- sands
            value = { sands\getPixel 511, math.min 511, math.floor (math.min 1, (value - 0.65) * (1/0.03) + 0.5) * 512 }
          elseif color[1] == 0.68
            value = { grass\getPixel 599, math.min 599, math.floor (math.min 1, (value - 0.68) * (1/0.03) + 0.5) * 600 }
          else
            value = color[2]
          break
      @map[x][y] = value

    if GARBAGE
      h = @altitude(x, y)
      p = @precipitation(x, y)

      t = @temperature(x, y)
      t = math.sqrt(t * (1 - h)) -- correct temperature according to altitude

      if h < 1/3
        map[x][y] = { 0, 0, 1 }
      else
        -- x is precipitation (0 to 599)
        -- y is temperature (0 to 599)
        t = math.min 599, math.floor t * 600
        p = math.min 599, math.floor p * 600
        map[x][y] = { biomes\getPixel p, t }
      if true return map[x][y]

      colors = {
        ocean: { 0, 0, 1, 1 }
        "fresh water": { 1/3, 1/3, 1, 1 }
        "deep ocean": { 0, 0, 2/3, 1 }
        "sandy desert": { 1, 1, 0, 1 }
        "rocky desert": { 1, 0.9, 0.1, 1 }
        "cold desert": { 1/3, 0.75, 0.75, 1 }
        swamp: { 65/255, 104/255, 37/255, 1 }
        beach: { 1, 1, 2/3, 1 }
        rainforest: { 0, 1, 0, 1 }
        "frozen ocean": { 0, 0.75, 0.75, 1 }
        ice: { 0, 0.9, 0.9, 1 }
        snow: { 1, 1, 1, 1 }
        tundra: { 0, 1/3, 2/3, 1 }
        grassland: { 1/3, 1, 0, 1 }

        undefined: { 1, 0, 0, 1 }
        white: { 1, 1, 1, 1 }
      }
      for biome, color in pairs colors
        table.insert color, biome

      biomes_old = {
        -- "frozen desert": { 1/3, 0.75, 0.76, 1, h: 0.5, p: 0.12, t: 0 }
        -- swamp: { 65/255, 104/255, 37/255, 1, h: 0.1, p: 1, t: 0.8 }
        -- -- savanna: { }
        -- -- shrubland: { }
        -- "broadleaf forest": { 0.2, 1, 0.2, 1, h: 0.6, p: 0.38, t: 0.4 }
        -- "evergreen forest": { 0, 0.75, 0, 1, h: 0.75, p: 0.46, t: 0.25 }
        -- "sandy desert": { 1, 1, 0.2, h: 0.45, p: 0, t: 0.5 }
        -- "baked desert": { 1, 0.75, 0.2, h: 0.5, p: 0, t: 1 }
        -- tundra: { 0, 1/3, 2/3, 1, h: 0.5, p: 0, t: 0 }
        -- -- tiaga: { }
        -- snow: { 0.9, 0.9, 0.9, 1, h: 0.8, p: 1, t: 0.05 }
        -- ice: { 0, 0.95, 0.95, 1, h: 1, p: 0.9, t: 0 }
        -- rainforest: { 0, 1, 0, 1, h: 0.4, p: 1, t: 1 }
        -- grassland: { 1/3, 1, 0, 1, h: 0.52, p: 0.18, t: 0.5 }
        "bright green": { 0.2, 1, 0.2, 1, h: 0.5, p: 0, t: 0 }
        green: { 0, 1, 0, 1, h: 0.5, p: 0, t: 1 }
        "dark green": { 0, 0.2, 0, 1, h: 0.5, p: 1, t: 0.5 }
      }
      d2 = (h, p, t, b) ->
        dh = h - b.h
        dp = p - b.p
        dt = t - b.t
        return dh^2 + dp^2 + dt^2
      choices = {}
      for name, value in pairs biomes_old
        table.insert choices, { d2(h, p, t, value), name, value }
      table.sort choices, (A, B) -> return A[1] < B[1]
      copy = (t) ->
        n = {}
        for k,v in pairs t
          n[k] = v
        return n
      merge = (A, B, f) ->
        r = math.sqrt A[1]^2 + B[1]^2
        g = math.sqrt A[2]^2 + B[2]^2
        b = math.sqrt A[3]^2 + B[3]^2
        a = math.sqrt (A[4] or 1)^2 + (B[4] or 1)^2
        return { r, g, b, a or 1 }
      -- map[x][y] = merge choices[1][3], choices[2][3], choices[1][1] - choices[2][1]
      -- map[x][y][5] = "#{choices[1][2]}: #{tostring(h)\sub 1, 4}, #{tostring(p)\sub 1, 4}, #{tostring(t)\sub 1, 4}"

      -- t = math.min 9, math.floor t * 10
      -- p = math.min 9, math.floor p * 10
      -- map[x][y] = { biomes\getPixel t, 9 - p }

      unless map[x][y]
        map[x][y] = colors.undefined
