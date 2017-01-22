Promise = require("bluebird")
req = Promise.promisify(require("request"))
_ = require("lodash")
InvalidResponseError = require("../errors").InvalidResponseError
json = []

fs = require('fs');
config = JSON.parse(fs.readFileSync(__dirname + '/config.json', 'utf8'));

cryptoid = (addr) ->
  currency = switch
    when addr[0] == 'X' then 'dash'
    when addr[0] == 'C' then 'cpc'
    when addr[0] == 'P' then 'ppc'
    when addr[0] == 'R' then 'rby'
    when addr[0] == 'G' then 'grt'
    else 'blk'

  url = config["cryptoid"].replace("[addr]", addr).replace("[currency]", currency)
  req(url, json: true)
    .timeout(2000)
    .cancellable()
    .spread (resp) ->
      if resp.statusCode in [200..299]
        status: "success"
        service: url
        address: addr
        quantity: resp.body.toString()
        asset: currency.toUpperCase()
      else
        if _.isObject(json) and json.message == "error"
          []
        else
          throw new InvalidResponseError service: url, response: resp

    .catch Promise.TimeoutError, (e) ->
      [status: 'error', service: url, message: e.message, raw: e]
    .catch InvalidResponseError, (e) ->
      [status: "error", service: e.service, message: e.message, raw: e.response]

module.exports = cryptoid
