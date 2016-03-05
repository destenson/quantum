Promise = require("bluebird")
req = Promise.promisify(require("request"))
InvalidResponseError = require("../errors").InvalidResponseError
converter = require("./../converter")

factom = (addr) ->
  url = "http://node.cyber.fund:8077/v1/factoid-balance/#{addr}"

  req(url, json: true)
    .timeout(3000)
    .cancellable()
    .spread (resp, json) ->
      if resp.statusCode in [200..299]
        status: "success"
        service: "http://localhost:8089"
        address: addr
        asset: "Factoids"
        quantity: converter.toCoin(json.Response, "Factoids")
      else
        if _.isObject(json) and json.message == "error"
          []
        else
          throw new InvalidResponseError service: url, response: resp

    .catch Promise.TimeoutError, (e) ->
      [status: 'error', service: url, message: e.message, raw: e]
    .catch InvalidResponseError, (e) ->
      [status: "error", service: e.service, message: e.message, raw: e.response]

module.exports = factom
