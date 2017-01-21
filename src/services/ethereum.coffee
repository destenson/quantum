Promise = require("bluebird")
req = Promise.promisify(require("request"))
_ = require("lodash")
InvalidResponseError = require("../errors").InvalidResponseError
converter = require("./../converter")

tokens = []
ethereum = (addr) ->
  url = "https://api.cyber.fund/Ethereum/address/#{addr}"

  req(url)
    .timeout(5000)
    .cancellable()
    .spread (resp, json) ->
      if resp.statusCode in [200..299]
        json = JSON.parse(json)
        systems = Object.keys(json)
        for system in systems
          quantity = if converter.isConversion(system) then converter.toCoin(json[system], system) else json[system]
          tokens.push({
              asset: system
              quantity: parseFloat(quantity)
            })
        tokens
      else
        if _.isObject(json) and json.message == "error"
          []
        else
          throw new InvalidResponseError service: url, response: resp
    .map (token) ->
        status: "success"
        service: token.service
        address: addr
        asset: token.asset
        quantity: token.quantity
    .catch Promise.TimeoutError, (e) ->
      console.log("Hi!!")
      [status: 'error', service: url, message: e.message, raw: e]
    .catch InvalidResponseError, (e) ->
      console.log("Hi!!!!")
      [status: "error", service: e.service, message: e.message, raw: e.response]

module.exports = ethereum
