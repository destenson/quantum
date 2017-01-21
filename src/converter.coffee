Big = require('big.js')

conversion = {
  "BTC": 100000000,
  "ETC": 1000000000000000000,
  "ETH": 1000000000000000000,
  "FCT": 100000000,
  "LSK": 100000000,
  "NXT": 100000000,
  "XEM": 1000000
}

module.exports =
  toCoin: (basicAmount, type) ->
    if (typeof basicAmount == 'string')
      basicAmount = Number(basicAmount)
    bigBasicAmount = new Big(basicAmount)
    Number(bigBasicAmount.div(conversion[type])).toString()

  isConversion: (system) ->
    if (system in conversion) then true else false
