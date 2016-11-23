Promise = require("bluebird")
req = Promise.promisify(require("request"))
_ = require("lodash")
InvalidResponseError = require("../errors").InvalidResponseError
converter = require("./../converter")
token = require("./../../../token.json").token
service = "https://api.blockcypher.com"

blockcypher = (addr) ->
  url = "https://api.blockcypher.com/v1/btc/main/addrs/#{addr}/balance?token="+token
  req(url, json: true)
    .timeout(5000)
    .cancellable()
    .spread (resp, json) ->
      if resp.statusCode in [200..299]
        status: "success"
        service: service
        address: addr
        quantity: converter.toCoin(json.balance, "BTC")
        quantity_unconfirmed: converter.toCoin(json.final_balance, "BTC")
        asset: 'BTC'
      else
        if _.isObject(json) and json.message == "error"
          []
        else
          throw new InvalidResponseError service: url, response: resp
    .catch Promise.TimeoutError, (e) ->
      [status: 'error', service: url, message: e.message, raw: e]
    .catch InvalidResponseError, (e) ->
      [status: "error", service: e.service, message: e.message, raw: e.response]

module.exports = blockcypher
