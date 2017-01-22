Promise = require("bluebird")
req = Promise.promisify(require("request"))
_ = require("lodash")
InvalidResponseError = require("../errors").InvalidResponseError
converter = require("./../converter")
fs = require('fs');
config = JSON.parse(fs.readFileSync(__dirname + '/config.json', 'utf8'));

tokens = []
ethereum = (addr) ->
  url = config["ethereum"].replace("[addr]", addr)

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
        service: url
        address: addr
        asset: token.asset
        quantity: token.quantity
    .catch Promise.TimeoutError, (e) ->
      [status: 'error', service: url, message: e.message, raw: e]
    .catch InvalidResponseError, (e) ->
      [status: "error", service: e.service, message: e.message, raw: e.response]

module.exports = ethereum
