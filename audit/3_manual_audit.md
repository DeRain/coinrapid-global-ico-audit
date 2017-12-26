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
| Lines | Code sample                                                                                        | Issue                                                                                                       | Priority | Resolved |
|-------|----------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------|----------|----------| 
| 2     | contract Ownable {                                                                                 | Contract implementation could be replaced by the OpenZeppelin Ownable contract                              | Low      | Yes      |
| 6-10  | if (owner == msg.sender) {                                                                         | Could be replaced by the require(owner == msg.sender); _;                                                   | Low      | Yes      |
| 20    | library SafeMath {                                                                                 | Could be replaced by OpenZeppelin SafeMath                                                                  | Low      | Yes      |
| 46    | contract Mortal is Ownable {                                                                       | Not a good practice to allow the destroy the token contract                                                 | Medium   | Yes      |
| 53    | contract Pausable is Mortal {                                                                      | Could be replaced by OpenZeppelin contract                                                                  | Low      | Yes      |
| 108   | contract BasicToken is ERC20Basic, Pausable {                                                      | Could be replaced by OpenZeppelin contract                                                                  | Low      | Yes      |
| 149   | contract StandardToken is ERC20, BasicToken {                                                      | Could be replaced by OpenZeppelin contract                                                                  | Low      | Yes      |
| 164   | if (balances[_from] >= _value && allowance(_from, _to) >= _value) {                                | Condition could be replaced by require() method                                                             | Low      | Yes      |
| 195   | function allowance(address _owner, address _spender) public constant returns (uint256 remaining) { | Checking of allowance should be restricted to the spender only                                              | Medium   | Yes      |
| 228   | string public constant version = '1.0';                                                            | If token will be upgraded it would be better to use ERC644 token https://github.com/ethereum/EIPs/issues/644| Low      | Yes      |
| 238   | //TODO presale 4 weeks but full sale start after 4 week                                            | Unresolved TODO                                                                                             | Low      | **No**   |
| 244   | amountRaised = 0;                                                                                  | amountRaised equal to zero be default. No need to assign zero again.                                        | Low      | Yes      |
| 260   | if(now < (preSaleStartDate  + 7 * 1  days)){                                                       | Unclear conditions. Possible could be replaced by: preSaleStartDate  + 7 days                               | Medium   | Yes      |
| 262   | }else if (now < (preSaleStartDate  +14 * 1  days)){                                                | Unclear conditions. Possible could be replaced by: preSaleStartDate  + 14 days                              | Medium   | Yes      |
| 276   | allowed[owner][msg.sender]+=tokens;                                                                | This hack could be replaced by initial allowance of spend tokens from owner by the contract                 | Low      | **No**   |
| 287   | _accountByOwner.transfer(amountRaised);                                                            | Possibility to transfer funds to wrong address.                                                             | High     | Yes      |
| 300   | _accountByOwner.transfer(balanceToTransfer);                                                       | Possibility to transfer funds to wrong address.                                                             | High     | Yes      |
| 290   | function resetTokenOfAddress(address _userAdd)public onlyOwner {                                   | Warning! Owner could reset tokens of any investors in any time.                                             | High     | Yes      |
| 286   | require(amountRaised > 0);                                                                         | Warning! amountRaised will always be zero so the fund will be locked in the contract!                       | High     | Yes      |
| 287   | _accountByOwner.transfer(amountRaised);                                                            | Warning! amountRaised will always be zero so the fund will be locked in the contract!                       | High     | Yes      |
| 299   | require(amountRaised > balanceToTransfer);                                                         | Warning! amountRaised will always be zero so the fund will be locked in the contract!                       | High     | Yes      |
| 301   | amountRaised -= balanceToTransfer;                                                                 | Warning! amountRaised will always be zero so the fund will be locked in the contract!                       | High     | Yes      |
| 164   | if (balances[_from] >= _value && allowance(_from, _to) >= _value) {                                | Warning! Allocation should be checked for msg.sender, not for to address                                    | High     | Yes      |


**Update 1:** Most of issues was resolved by moving to OpenZeppelin framework and it's implementation of `StandardToken`, `Pausable` and `Ownable` contracts.
Danger method `resetTokenOfAddress` was removed. Methods `transferLimitedFundToAccount` and `transferFundToAccount` was removed in favor to direct transfer ether to owner wallet and smart contract does not store funds anymore.   
We still have two unresolved issues in **Low** priority, but this issues does not affect on proper work of smart contract.   
As a best practice I recommend to use `MultiSig Wallet` instead of the address of contract own to receive ether from investors. [Gnosis Multisig Wallet.](https://github.com/gnosis/MultiSigWallet)  
        
Commit: [9e49bbcd697baeef6d52c318a9bb34a28ef29a93](https://github.com/DeRain/coinrapid-global-ico-audit/commit/9e49bbcd697baeef6d52c318a9bb34a28ef29a93)  

   