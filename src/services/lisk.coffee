Promise = require("bluebird")
req = Promise.promisify(require("request"))
_ = require("lodash")
InvalidResponseError = require("../errors").InvalidResponseError
converter = require("./../converter")

lisk = (addr) ->
  req('https://login.lisk.io/api/accounts/getBalance',
      qs: {'address': addr},
      json: true
    )
    .timeout(3000)
    .cancellable()
    .spread (resp, json) ->
      if resp.statusCode in [200..299]
        status: "success"
        service: "https://login.lisk.io"
        address: addr
        quantity: converter.toCoin(json.balance, "LSK")
        asset: "LSK"
      else
        if _.isObject(json) and json.message == "error"
          []
        else
          throw new InvalidResponseError service: url, response: resp

    .catch Promise.TimeoutError, (e) ->
      [status: 'error', service: url, message: e.message, raw: e]
    .catch InvalidResponseError, (e) ->
      [status: "error", service: e.service, message: e.message, raw: e.response]

module.exports = lisk
