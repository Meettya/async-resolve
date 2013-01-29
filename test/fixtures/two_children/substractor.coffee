# simple module

power = require './power'

substractor = (a, b) -> a - b
substractor_pow = (a, b) -> power substractor a, b

module.exports =
  substractor : substractor
  substractor_pow : substractor_pow