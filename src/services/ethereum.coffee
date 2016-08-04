Promise = require("bluebird")
req = Promise.promisify(require("request"))
_ = require("lodash")
InvalidResponseError = require("../errors").InvalidResponseError
converter = require("./../converter")

Web3 = require('web3')
web3 = new Web3()
web3.setProvider(new web3.providers.HttpProvider('http://node.cyber.fund:8555'))

balances = []

ethereum = (addr) ->
  url = "http://api.etherscan.io/api?module=account&action=balance&address=#{addr}&tag=latest "

  req(url, json: true)
    .timeout(2000)
    .cancellable()
    .spread (resp, json) ->
      if resp.statusCode in [200..299]
        balances = [{
          service: "http://api.etherscan.io"
          asset: "ETH"
          quantity: json.result
        }, {
          service: "http://node.cyber.fund"
          asset: "ETC"
          quantity: web3.eth.getBalance(addr)
        }]
        balances
      else
        if _.isObject(json) and json.message == "error"
          []
        else
          throw new InvalidResponseError service: url, response: resp
    .map (token) ->
        status: "success"
        service: token.service
        address: addr
        asset: token.asset
        quantity: converter.toCoin(token.quantity, token.asset)
    .catch Promise.TimeoutError, (e) ->
      [status: 'error', service: url, message: e.message, raw: e]
    .catch InvalidResponseError, (e) ->
      [status: "error", service: e.service, message: e.message, raw: e.response]

module.exports = ethereum
