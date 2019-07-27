import random, noise from love.math

biomes = love.image.newImageData "biomes3.png"

class World
  new: =>
    @generateSeed!
  get: (x, y) =>
    map = @map
    unless map[x]
      map[x] = {}
    unless map[x][y]
      h = @altitude(x, y)
      p = @precipitation(x, y)

      t = @temperature(x, y)
      t = math.sqrt(t * (1 - h)) -- correct temperature according to altitude

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

      biomes = {
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
      for name, value in pairs biomes
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
        a = math.sqrt (A[4] or 1)^2 + ((B[4] or 1)^2
        return { r, g, b, a or 1 }
      map[x][y] = merge choices[1][3], choices[2][3], choices[1][1] - choices[2][1]
      map[x][y][5] = "#{choices[1][2]}: #{tostring(h)\sub 1, 4}, #{tostring(p)\sub 1, 4}, #{tostring(t)\sub 1, 4}"

      -- t = math.min 9, math.floor t * 10
      -- p = math.min 9, math.floor p * 10
      -- map[x][y] = { biomes\getPixel t, 9 - p }

      unless map[x][y]
        map[x][y] = colors.undefined

    return map[x][y]
  generateSeed: =>
    @map = {}
    @sealevel = random! * 0.06 + 0.05 -- 0.05 to 0.11
    @precipitationXOffset = random! * 256
    @precipitationYOffset = random! * 256
    @precipitationScale = random! * 0.009 + 0.001
    @temperatureXOffset = random! * 256
    @temperatureYOffset = random! * 256
    @temperatureScale = random! * 0.009 + 0.001
    @altitudeXOffset = random! * 256
    @altitudeYOffset = random! * 256
    @altitudeScale = random! * 0.009 + 0.001
    @altitudeAmplitude = random! * 0.9 + 0.1 -- max: 1, min: 0.1
    @altitudeXOffset2 = random! * 256
    @altitudeYOffset2 = random! * 256
    @altitudeScale2 = random! * 0.012 + 0.008
    @altitudeAmplitude2 = random! * 0.09 + 0.01 -- max: 0.1, min: 0.01
    @altitudeXOffset3 = random! * 256
    @altitudeYOffset3 = random! * 256
    @altitudeScale3 = random! * 0.092 + 0.01
    @altitudeAmplitude3 = random! * 0.009 + 0.001 -- max: 0.01, min: 0.001
  precipitation: (x, y) =>
    return noise((x + @precipitationXOffset) * @precipitationScale, (y + @precipitationYOffset) * @precipitationScale)
  temperature: (x, y) =>
    return noise((x + @temperatureXOffset) * @temperatureScale, (y + @temperatureYOffset) * @temperatureScale)
  altitude: (x, y) =>
    h = noise((x + @altitudeXOffset) * @altitudeScale, (y + @altitudeYOffset) * @altitudeScale) * @altitudeAmplitude +
      noise((x + @altitudeXOffset2) * @altitudeScale2, (y + @altitudeYOffset2) * @altitudeScale2) * @altitudeAmplitude2 +
      noise((x + @altitudeXOffset3) * @altitudeScale3, (y + @altitudeYOffset3) * @altitudeScale3) * @altitudeAmplitude3
    -- max: 1.11, min: 0.111
    -- slope = (output_end - output_start) / (input_end - input_start)
    -- output = output_start + slope * (input - input_start)
    slope = 1 / (1.11 - 0.111)
    return slope * (h - 0.111)
