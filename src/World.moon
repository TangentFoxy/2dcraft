import random, noise from love.math

class World
  new: =>
    @generateSeed!
  get: (x, y) =>
    map = @map
    unless map[x]
      map[x] = {}
    unless map[x][y]
      p = @precipitation(x, y)
      -- map[x][y] = { 1 - p, 1 - p, 1, 1 }
      h = @height(x, y)
      -- map[x][y] = { h, h, h, 1 }
      t = @temperature(x, y)
      -- map[x][y] = { t, 0, 0, 1 }
      map[x][y] = { t, h, p, 1 }
    return map[x][y]
  generateSeed: =>
    @map = {}
    @precipitationXOffset = random! * 256
    @precipitationYOffset = random! * 256
    @precipitationScale = random! * 0.009 + 0.001
    @temperatureXOffset = random! * 256
    @temperatureYOffset = random! * 256
    @temperatureScale = random! * 0.009 + 0.001
    @heightXOffset = random! * 256
    @heightYOffset = random! * 256
    @heightScale = random! * 0.009 + 0.001
    @heightAmplitude = random! * 0.9 + 0.1 -- max: 1, min: 0.1
    @heightXOffset2 = random! * 256
    @heightYOffset2 = random! * 256
    @heightScale2 = random! * 0.012 + 0.008
    @heightAmplitude2 = random! * 0.09 + 0.01 -- max: 0.1, min: 0.01
    @heightXOffset3 = random! * 256
    @heightYOffset3 = random! * 256
    @heightScale3 = random! * 0.092 + 0.01
    @heightAmplitude3 = random! * 0.009 + 0.001 -- max: 0.01, min: 0.001
  precipitation: (x, y) =>
    return noise((x + @precipitationXOffset) * @precipitationScale, (y + @precipitationYOffset) * @precipitationScale)
  temperature: (x, y) =>
    return noise((x + @temperatureXOffset) * @temperatureScale, (y + @temperatureYOffset) * @temperatureScale)
  height: (x, y) =>
    h = noise((x + @heightXOffset) * @heightScale, (y + @heightYOffset) * @heightScale) * @heightAmplitude +
      noise((x + @heightXOffset2) * @heightScale2, (y + @heightYOffset2) * @heightScale2) * @heightAmplitude2 +
      noise((x + @heightXOffset3) * @heightScale3, (y + @heightYOffset3) * @heightScale3) * @heightAmplitude3
    -- max: 1.11, min: 0.111
    -- slope = (output_end - output_start) / (input_end - input_start)
    -- output = output_start + slope * (input - input_start)
    slope = 1 / (1.11 - 0.111)
    return slope * (h - 0.111)
