
{sub} = require 'substitutor'
{summator} = require 'summator'

dev = (a, b) -> a / b
calculate = (a, b) -> 
  dev sub(a,b), summator(a,b) # 10, 5 -> (10-5) / (10+5) = 0,3

# simple module
module.exports = {
  dev, calculate
}

