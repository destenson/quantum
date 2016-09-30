Promise = require("bluebird")
req = Promise.promisify(require("request"))
_ = require("lodash")
InvalidResponseError = require("../errors").InvalidResponseError
converter = require("./../converter")

blockcypher = (addr) ->
  console.log(addr, "11111111")
  url = "https://api.blockcypher.com/v1/btc/main/addrs/#{addr}/balance"
  req(url, json: true)
    .timeout(5000)
    .cancellable()
    .spread (resp, json) ->
      ###
      {
      "address": "1DEP8i3QJCsomS4BSMY2RpU1upv62aGvhD",
      "total_received": 4433416,
      "total_sent": 0,
      "balance": 4433416,
      "unconfirmed_balance": 0,
      "final_balance": 4433416,
      "n_tx": 7,
      "unconfirmed_n_tx": 0,
      "final_n_tx": 7
      }
      ###
      if resp.statusCode in [200..299]
        status: "success"
        service: "https://api.blockcypher.com"
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
