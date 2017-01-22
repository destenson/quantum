bs58check = require('bs58check')

module.exports =
  bitshares: (addr) ->
    RegExp('^(bitshares-)[a-z0-9-.]{1,15}$').test(addr)

  bitcoin: (addr) ->
    RegExp('^[13][a-km-zA-HJ-NP-Z1-9]{25,34}$').test(addr)

  litecoin: (addr) ->
    RegExp('^L[a-km-zA-HJ-NP-Z1-9]{33}$').test(addr)

  counterparty: (addr) ->
    RegExp('^[13][a-km-zA-HJ-NP-Z1-9]{25,34}$').test(addr)

  cryptoid: (addr) ->
    RegExp('^[CGRXPB][a-km-zA-HJ-NP-Z1-9]{33}$').test(addr)

  doge: (addr) ->
    RegExp('^D[a-km-zA-HJ-NP-Z1-9]{33}$').test(addr)

  ethereum: (addr) ->
    RegExp('^(0x)?[0-9a-fA-F]{40}$').test(addr)

  factom: (addr) ->
    if addr.length != 52
      return false
    try decoded = bs58check.decode(addr)
    catch error
      return false
    decoded[0] == (95 || 177)

  lisk: (addr) ->
    RegExp('^[0-9]{19}L$').test(addr)

  nem: (addr) ->
    RegExp('^[nN][a-zA-Z0-9]{5}(-[a-zA-Z0-9]{4,6}){6}$').test(addr)

  nxt: (addr) ->
    RegExp('^(NXT|nxt)(-[a-zA-Z0-9]{4,5}){4}$').test(addr)

  nxtassets: (addr) ->
    RegExp('^(NXT|nxt)(-[a-zA-Z0-9]{4,5}){4}$').test(addr)

  omni: (addr) ->
    RegExp('^[13][a-km-zA-HJ-NP-Z1-9]{25,34}$').test(addr)

  openassets: (addr) ->
    try decoded = bs58check.decode(addr)
    catch error
      return false
    decoded[0] == 19

  ripple: (addr) ->
    RegExp('^r[1-9A-HJ-NP-Za-km-z]{25,33}$').test(addr)

  steem: (addr) ->
    RegExp('^(steem-)[a-z0-9-.]{1,15}$').test(addr)

  golos: (addr) ->
    RegExp('^(golos-)[a-z0-9-.]{1,15}$').test(addr)
