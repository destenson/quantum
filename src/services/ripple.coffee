Promise = require("bluebird")
req = Promise.promisify(require("request"))
_ = require("lodash")
InvalidResponseError = require("../errors").InvalidResponseError
fs = require('fs');
config = JSON.parse(fs.readFileSync(__dirname + '/config.json', 'utf8'));

ripple = (addr) ->
  url = config["ripple"].replace("[addr]", addr)

  req(url, json: true)
    .timeout(2000)
    .cancellable()
    .spread (resp, json) ->
      if resp.statusCode in [200..299] and _.isArray(json.balances)
        json.balances
      else
        if _.isObject(json) and json.message == "error"
          []
        else
          throw new InvalidResponseError service: url, response: resp
    .filter (item) ->
      item.value != '0'
    .map (asset) ->
      status: "success"
      service: url
      address: addr
      quantity: asset.value
      asset: asset.currency

    .catch Promise.TimeoutError, (e) ->
      [status: 'error', service: url, message: e.message, raw: e]
    .catch InvalidResponseError, (e) ->
      [status: "error", service: e.service, message: e.message, raw: e.response]

module.exports = ripple
