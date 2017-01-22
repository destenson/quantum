Promise = require("bluebird")
req = Promise.promisify(require("request"))
_ = require("lodash")
InvalidResponseError = require("../errors").InvalidResponseError
fs = require('fs');
config = JSON.parse(fs.readFileSync(__dirname + '/config.json', 'utf8'));

property_map = {
  1: 'Omni',
  3: 'MSC',
  56: 'SEC',
  39: 'AMP',
  31: 'USDT',
  35: 'TAU',
  44: 'ZOOZ'
}

chaingear_map = {
  1: 'MSC',
  3: 'MAID',
  56: 'SEC',
  39: 'AMP',
  31: 'USDT',
  35: 'TAU',
  44: 'ZOOZ'
}

omni = (addr) ->
  url = config["omni"].replace("[addr]", addr)
  Promise
    .all Object.keys(property_map)
    .map (property_id) ->
      tb = url.replace("[property_id]", property_id)
      req(tb)
        .timeout(3000)
        .cancellable()
        .spread (resp, json) ->
          if resp.statusCode in [200..299]
            status: "success"
            service: url
            address: addr
            quantity: json
            asset: chaingear_map[property_id]
          else
            throw new InvalidResponseError service: url, response: resp
    .filter (item) ->
      item.quantity != 0

    .catch Promise.TimeoutError, (e) ->
      [status: 'error', service: url, message: e.message, raw: e]
    .catch InvalidResponseError, (e) ->
      [status: "error", service: e.service, message: e.message, raw: e.response]
module.exports = omni
