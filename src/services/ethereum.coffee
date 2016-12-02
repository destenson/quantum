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
  console.log(addr)
  url = "http://api.cyber.fund/geth/Ethereum/address/#{addr}"
  console.log(url)
  req(url, json: true)
    .timeout(15000)
    .cancellable()
    .spread (resp, json) ->
      console.log("ETHER status", resp.statusCode)
      console.log("resp.statusCode === 200", resp.statusCode == 200)
      if resp.statusCode == 200
        console.log("here", json, JSON.parse(json))
        ret = null
        try
          ret = JSON.parse(json)
        catch e
          console.log('could not parse json')

        #balances = [{
        #  status: "success"
        #  service: "http://node.cyber.fund"
        #  address: addr
        #  asset: "ETC"
        #  quantity: web3.eth.getBalance(addr)
        #}]
        balances = []
        _.each ret, (v, k)->
          balances.push({
            status: "success"
            service: "http://api.cyber.fund"
            asset: k
            quantity: if typeof v == 'string' then parseFloat(v) else v
            address: addr})
      else
        if _.isObject(json) and json.message == "error"
          []
        else
          throw new InvalidResponseError service: url, response: resp
      return balances
    #.map (token) ->
    #    status: "success"
    #    service: token.service
    #    address: addr
    #    asset: token.asset
    #    quantity: token.quantity#//converter.toCoin(token.quantity, token.asset)
    .catch Promise.TimeoutError, (e) ->
      [status: 'error', service: url, message: e.message, raw: e]
    .catch InvalidResponseError, (e) ->
      [status: "error", service: e.service, message: e.message, raw: e.response]

module.exports = ethereum
