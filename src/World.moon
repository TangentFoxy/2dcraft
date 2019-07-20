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
      -- map[x][y] = { h, h, h, 1 }
      p = @precipitation(x, y)
      -- p = math.sqrt(p * (1 - h)) -- correct precipitation according to altitude
      -- map[x][y] = { 1 - p, 1 - p, 1, 1 }

      t = @temperature(x, y)
      -- map[x][y] = { t, 0, 0, 1 }
      t = math.sqrt(t * (1 - h)) -- correct temperature according to altitude
      -- map[x][y] = { t, h, p, 1 }

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

      -- biome, probability = "undefined", 0
      -- for name, fn in pairs biomes
      --   t = fn(t, h, p)
      --   if t > probability
      --     biome = name
      --     probability = t
      -- map[x][y] = colors[biome]

      -- temperature is x value
      -- precipitation is y value (inverted)
      t = math.min 9, math.floor t * 10
      p = math.min 9, math.floor p * 10
      -- print t, p
      map[x][y] = { biomes\getPixel t, 9 - p }

      unless map[x][y]
        map[x][y] = colors.white

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
