Promise = require("bluebird")
fs = require('fs');
req = Promise.promisify(require("request"))
_ = require("lodash")
InvalidResponseError = require("../errors").InvalidResponseError
config = JSON.parse(fs.readFileSync(__dirname + '/config.json', 'utf8'));

bitAssets = {
  CNY: 'BITCNY',
  USD: 'BITUSD',
  BTC: 'BITBTC',
  SILVER: 'BITSILVER',
  GOLD: 'BITGOLD',
  EUR: 'BITEUR'
}

url = config["bitshares"]

options =
  url: url,
  method: 'GET',
  headers: {
    'Content-Type': 'application/json-rpc',
    'Accept': 'application/json-rpc'
  }
bitshares = (account) ->
  addr = account.split('-')[1]
  options.body =
    JSON.stringify(
      'jsonrpc': '2.0',
      'method': 'get_named_account_balances',
      'params': [addr,[]],
      'id': Math.random()
    )
  req(options)
    .timeout(3000)
    .cancellable()
    .spread (resp, json) ->
      json = JSON.parse(json)
      if resp.statusCode in [200..299] and _.isArray(json.result)
        # console.log(json)
        json.result
      else
        if _.isObject(json) and json.message == "error"
          []
        else
          throw new InvalidResponseError service: url, response: resp
    .map (asset) ->
      options.body =
        JSON.stringify(
          "jsonrpc": "2.0",
          "method": "get_assets",
          "params":[[asset.asset_id]],
          "id": Math.random()
        )
      req(options)
        .timeout(2000)
        .cancellable()
        .spread (resp, json) ->
          json = JSON.parse(json)
          if resp.statusCode in [200..299]
            if _.isNull json
              _.merge asset, name: "#{asset.asset_id}", divisibility: 0
            else if json.asset == asset.asset
              _.merge asset, name: "#{json.result[0].symbol}", divisibility: json.result[0].precision
          else
            throw new InvalidResponseError service: url, response: resp
    .map (asset) ->
      balance = parseInt(asset.amount, 10)
      quantity = balance / (10 ** asset.divisibility)
      token = if _.has(bitAssets, asset.name) then bitAssets[asset.name] else asset.name

      status: "success"
      service: url
      address: account
      quantity: quantity
      asset: token
    .filter (item) ->
      item.quantity != 0

    .catch Promise.TimeoutError, (e) ->
      [status: 'error', service: url, message: e.message, raw: e]
    .catch InvalidResponseError, (e) ->
      [status: "error", service: e.service, message: e.message, raw: e.response]

module.exports = bitshares
