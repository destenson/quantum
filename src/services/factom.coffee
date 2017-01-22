Promise = require("bluebird")
req = Promise.promisify(require("request"))
InvalidResponseError = require("../errors").InvalidResponseError
converter = require("./../converter")
fs = require('fs');
config = JSON.parse(fs.readFileSync(__dirname + '/config.json', 'utf8'));

factom = (addr) ->
  url = config["factom"].replace("[addr]", addr)

  req(url, json: true)
    .timeout(3000)
    .cancellable()
    .spread (resp, json) ->
      if resp.statusCode in [200..299]
        status: "success"
        service: url
        address: addr
        asset: "FCT"
        quantity: converter.toCoin(json.Response, "FCT")
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
