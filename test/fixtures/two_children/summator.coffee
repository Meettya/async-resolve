# simple module

power = require './power'

summator = (a, b) -> a + b
summator_pow = (a, b) -> power summator a, b

module.exports =
  summator : summator
  summator_pow : summator_pow