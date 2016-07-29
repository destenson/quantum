# Quantum
[![Join the chat at https://gitter.im/cyberFund/quantum](https://badges.gitter.im/cyberFund/quantum.svg)](https://gitter.im/cyberFund/quantum?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Easy check addresses balances of various crypto tokens. Script automaticaly recognize a protocol by address and return balance of tokens associated with it. Token names are resolved using Chaingear.

Maintainer @ValeryLitvin and @21xhipster

On repo project folder type:
```
~ » npm run balance 0xfc30a6c6d1d61f0027556ed25a670345ab39d0cb

  { status: 'success',
  service: 'http://api.etherscan.io',
  address: '0xfc30a6c6d1d61f0027556ed25a670345ab39d0cb',
  asset: 'ETH',
  quantity: '0.29' }

  0.29 ETH
```

## Node.js

```
var balance = require('quantum');
balance("0xfc30a6c6d1d61f0027556ed25a670345ab39d0cb", function(error, result) {
  console.log(result);
});

[{"quantity":"0.29","asset":"ETH"}]
```

## Supported Protocols

- Using `https://chain.so`: Bitcoin, Litecoin
- Using `http://dogechain.info`: Dogecoin
- Using `http://etherscan.io`: Ethereum
- Using `http://node.cyber.fund`: Ethereum Classic (port 8555)
- Using `http://node2.cyber.fund`: Steem, SBD, Steem Power with Nickname (on port 8091)
- Using `http://node.cyber.fund`: BitShares with account's ID (on port 8055)
- Using `http://blockscan.com`: Counterparty
- Using `https://api.coinprism.com`: Open Assets Protocol
- Using `https://api.ripple.com`: Ripple and Ripple based IOUs
- Using `http://omnichest.info`: Omni
- Using `http://node.cyber.fund`: NXT and NXT AE (on port 7877)
- Using `http://bigalice3.nem.ninja`: NEM (on port 7890)
- Using `https://lisk.io`: Lisk
- Using `http://node.cyber.fund`: Factom (on port 8077) [temporarily turned off]
- Using `https://chainz.cryptoid.info`: Dash, PeerCoin, Blackcoin

## Installation

```
~ » git clone https://github.com/cyberFund/quantum
~ » cd quantum
~ » make init
~ » make build
```

## Tests
```
~ » npm test
```

## License

Under MIT License

## Contributing
1. Fork it
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create new Pull Request
