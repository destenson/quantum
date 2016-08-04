Promise = require("bluebird")
req = Promise.promisify(require("request"))
_ = require("lodash")
InvalidResponseError = require("../errors").InvalidResponseError

account_info =
  url    : "http://node2.cyber.fund:8091/rpc",
  method : 'GET',
  headers: {
    'Content-Type': 'application/json-rpc',
    'Accept': 'application/json-rpc'
  }

global_prop = JSON.parse(JSON.stringify(account_info))
global_prop.body = JSON.stringify(
    jsonrpc: '2.0',
    params : [0, "get_dynamic_global_properties", []]
    method : 'call',
    id     : Math.floor(Math.random() * 10000))
balances = []

steem = (account) ->
  addr = account.split('-')[1]
  account_info.body = JSON.stringify(
          jsonrpc: '2.0',
          params : [0, "get_accounts", [[addr]]],
          method : 'call',
          id     : Math.floor(Math.random() * 10000)
  )
  req(account_info)
    .timeout(300)
    .cancellable()
    .spread (resp, json) ->
      json = JSON.parse(json)
      if resp.statusCode in [200..299] and _.isArray(json.result)
        balances = [{name: 'STEEM', amount: parseFloat(json.result[0].balance, 10)},
                    {name: 'SBD', amount  : parseFloat(json.result[0].sbd_balance, 10)},
                    {name: 'SP', amount   : parseFloat(json.result[0].vesting_shares, 10)}]
      else
        if _.isObject(json) and json.message == "error"
          []
        else
          throw new InvalidResponseError service: url, response: resp
  req(global_prop)
    .timeout(300)
    .cancellable()
    .spread (resp, json) ->
      json = JSON.parse(json)
      if resp.statusCode in [200..299]
        price = parseFloat(json.result.total_vesting_fund_steem, 10) / parseFloat(json.result.total_vesting_shares, 10)
        balances[2].amount *= price
        balances
      else
        throw new InvalidResponseError service: url, response: resp
      balances
  .map (token) ->
    status: "success"
    service: "http://node.cyber.fund:8091/rpc"
    address: account
    quantity: token.amount
    asset: token.name

  .catch Promise.TimeoutError, (e) ->
    [status: 'error', service: url, message: e.message, raw: e]
  .catch InvalidResponseError, (e) ->
    [status: "error", service: e.service, message: e.message, raw: e.response]

module.exports = steem
