# Manual audit of the code

## Known attacks checklist
- Reentrancy: no
- Cross-function Race Conditions: no
- Transaction-Ordering Dependence (TOD): no
- Timestamp Dependence: no
- Integer Overflow and Underflow: no
- DoS with (Unexpected) revert: no
- DoS with Block Gas Limit: no
- Forcibly Sending Ether to a Contract: no  

## Common issues
1. Funds should not be stored in the contract. The best way - transfer fund on every transaction into multisig wallet.
2. Fallback method too complex. Move all logic into separate method.
3. Replace `transferLimitedFundToAccount` and `transferFundToAccount` methods by the direct transfer of fund on external account/contract (multisig wallet).  
4. Method `resetTokenOfAddress` provides access to all bough tokens from the owner account.  

## RapidCoin.sol
| Lines | Code sample                                                                                        | Issue                                                                                                       | Priority |
|-------|----------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------|----------|
| 2     | contract Ownable {                                                                                 | Contract implementation could be replaced by the OpenZeppelin Ownable contract                              | Low      |
| 6-10  | if (owner == msg.sender) {                                                                         | Could be replaced by the require(owner == msg.sender); _;                                                   | Low      |
| 20    | library SafeMath {                                                                                 | Could be replaced by OpenZeppelin SafeMath                                                                  | Low      |
| 46    | contract Mortal is Ownable {                                                                       | Not a good practice to allow the destroy the token contract                                                 | Medium   |
| 53    | contract Pausable is Mortal {                                                                      | Could be replaced by OpenZeppelin contract                                                                  | Low      |
| 108   | contract BasicToken is ERC20Basic, Pausable {                                                      | Could be replaced by OpenZeppelin contract                                                                  | Low      |
| 149   | contract StandardToken is ERC20, BasicToken {                                                      | Could be replaced by OpenZeppelin contract                                                                  | Low      |
| 164   | if (balances[_from] >= _value && allowance(_from, _to) >= _value) {                                | Condition could be replaced by require() method                                                             | Low      |
| 195   | function allowance(address _owner, address _spender) public constant returns (uint256 remaining) { | Checking of allowance should be restricted to the spender only                                              | Medium   |
| 228   | string public constant version = '1.0';                                                            | If token will be upgraded it would be better to use ERC644 tokenhttps://github.com/ethereum/EIPs/issues/644 | Low      |
| 238   | //TODO presale 4 weeks but full sale start after 4 week                                            | Unresolved TODO                                                                                             | High     |
| 244   | amountRaised = 0;                                                                                  | amountRaised equal to zero be default. No need to assign zero again.                                        | Low      |
| 260   | if(now < (preSaleStartDate  + 7 * 1  days)){                                                       | Unclear conditions. Possible could be replaced by: preSaleStartDate  + 7 days                               | Medium   |
| 262   | }else if (now < (preSaleStartDate  +14 * 1  days)){                                                | Unclear conditions. Possible could be replaced by: preSaleStartDate  + 14 days                              | Medium   |
| 276   | allowed[owner][msg.sender]+=tokens;                                                                | This hack could be replaced by initial allowance of spend tokens from owner by the contract                 | Low      |
| 287   | _accountByOwner.transfer(amountRaised);                                                            | Possibility to transfer funds to wrong address.                                                             | High     |
| 300   | _accountByOwner.transfer(balanceToTransfer);                                                       | Possibility to transfer funds to wrong address.                                                             | High     |
| 290   | function resetTokenOfAddress(address _userAdd)public onlyOwner {                                   | Warning! Owner could reset tokens of any investors in any time.                                             | High     |
| 286   | require(amountRaised > 0);                                                                         | Warning! amountRaised will always be zero so the fund will be locked in the contract!                       | High     |
| 287   | _accountByOwner.transfer(amountRaised);                                                            | Warning! amountRaised will always be zero so the fund will be locked in the contract!                       | High     |
| 299   | require(amountRaised > balanceToTransfer);                                                         | Warning! amountRaised will always be zero so the fund will be locked in the contract!                       | High     |
| 301   | amountRaised -= balanceToTransfer;                                                                 | Warning! amountRaised will always be zero so the fund will be locked in the contract!                       | High     |