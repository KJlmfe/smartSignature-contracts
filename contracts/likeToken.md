# Working contract

https://rinkeby.etherscan.io/address/0xf8dcf103d9151d7186f3318b0bac395f8106ad99

# APIs

## Creation
Calling `put(address _issuer, uint256 _tokenId)` verifies an ERC721 token belonging to `msg.sender` and opens an `Order` for sender to receive tip (and tippers to receive reward)

## Tipping
Calling `sponsor(uint256 _id) payable` with ETH tips `Order` with `_id` in orderbook.
- Issuer gets a cut
- Previous tippers can receive reward balance, up to amount they tipped.

`getTipBalance(uint256 _id, address tipper)` returns current tip balance of `tipper` at `Order #{_id}`.

## Reward
Calling `withdrawRewardBalance(uint256 _id)` withdraws all available reward balance of `msg.sender` at `Order #{_id}`.

`getTipRewardBalance(uint256 _id, address tipper)` returns current withdrawable reward balance of `tipper` at `Order #{_id}`.

# Stuff
`Order` is ERC721 item to receive others' tip, belonging to issuer.
Each `Order` contains ref to original token, issuer, and also tipping history:
  - `tip_balance_sum` is up-to-date sum of all non-rewarded balance

