Promise = require("bluebird")
req = Promise.promisify(require("request"))
_ = require("lodash")
InvalidResponseError = require("../errors").InvalidResponseError

property_map = {
  1: 'Omni',
  3: 'MSC',
  56: 'SEC',
  39: 'AMP',
  31: 'USDT',
  35: 'TAU',
  44: 'ZOOZ'
}

omni = (addr) ->
  Promise
    .all Object.keys(property_map)
    .map (property_id) ->
      url = "http://omnichest.info/requeststat.aspx?stat=balance&prop=#{property_id}&address=#{addr}"
      req(url, json: true)
        .timeout(4000)
        .cancellable()
        .spread (resp, json) ->
          if resp.statusCode in [200..299]
            status: "success"
            service: "http://omnichest.info"
            address: addr
            quantity: json
            asset: property_map[property_id]
          else
            throw new InvalidResponseError service: url, response: resp
    .filter (item) ->
      item.quantity != 0
      
    .catch Promise.TimeoutError, (e) ->
      [status: 'error', service: url, message: e.message, raw: e]
    .catch InvalidResponseError, (e) ->
      [status: "error", service: e.service, message: e.message, raw: e.response]
module.exports = omni
