Promise = require("bluebird")
req = Promise.promisify(require("request"))
_ = require("lodash")
InvalidResponseError = require("../errors").InvalidResponseError

nxt_assets = (addr) ->
  url = "http://node.cyber.fund:7877/nxt?requestType=getAccountAssets&account=#{addr}"

  req(url, json: true)
    .timeout(2000)
    .cancellable()
    .spread (resp, json) ->
      if resp.statusCode in [200..299] and _.isArray(json.accountAssets)
        json.accountAssets
      else
        if _.isObject(json) and json.message == "error"
          []
        else
          throw new InvalidResponseError service: url, response: resp
    .map (asset) ->
      assetUrl = "http://node.cyber.fund:7877/nxt?requestType=getAsset&asset=#{asset.asset}"
      req(assetUrl, json: true)
        .timeout(2000)
        .cancellable()
        .spread (resp, json) ->
          if resp.statusCode in [200..299]
            if _.isNull json
              _.merge asset, name: "#{asset.asset}", divisibility: 0
            else if json.asset == asset.asset
              _.merge asset, name: "#{json.name}", divisibility: json.decimals
          else
            throw new InvalidResponseError service: url, response: resp
    .map (asset) ->
      balance = parseInt(asset.quantityQNT, 10)
      quantity = balance / (10 ** asset.divisibility)

      status: "success"
      service: "http://node.cyber.fund:7877"
      address: addr
      quantity: quantity.toFixed(6)
      asset: asset.name

    .catch Promise.TimeoutError, (e) ->
      [status: 'error', service: url, message: e.message, raw: e]
    .catch InvalidResponseError, (e) ->
      [status: "error", service: e.service, message: e.message, raw: e.response]

module.exports = nxt_assets
