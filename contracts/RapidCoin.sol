pragma solidity 0.4.18;

import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import 'zeppelin-solidity/contracts/token/StandardToken.sol';
import 'zeppelin-solidity/contracts/lifecycle/Pausable.sol';

contract RapidCoin is StandardToken, Pausable {
    string public constant name = 'Rapidpay';
    uint public constant decimals = 18;
    string public constant symbol = 'RDP';
    uint amountRaised;
    uint public priceOfTokenPREICO=500000000000000;// 1 ETH = 2000 RDP
    uint public priceOfToken = 833333330000000; //1 ETH  =  1200 RDP
    uint256 tokenSaleLimit;
    uint256 preSaleStartDate;
    uint256 preSaleEndDate;
    uint256 saleStartDate;
    uint256 saleEndDate;
    address walletForBalanace;
    //TODO presale 4 weeks but full sale start after 4 week
    function RapidCoin () public {
        totalSupply = 10 * (10 ** 9) * (10 ** decimals); //10 billion
        tokenSaleLimit = 475 * (10 ** 7) * (10 ** decimals); //4.75 billions
        uint256 ownerTokens = totalSupply; //we assign 10 million to acccountant firstly. 
        balances[msg.sender] = ownerTokens;
        owner = msg.sender;
        walletForBalanace = msg.sender;
        preSaleStartDate = now;//1516840000000; //January 25 2018 00 : 00  UTC
        preSaleEndDate = 1519611199999; // FEB 26 2018 00 : 00 UTC
        saleStartDate = 1516840000000; //January 25 2018 00 : 00  UTC
        saleEndDate = 1515571199000; //January 10 2018 UTC 8 AM and 4 week after presale
    }
    function () external payable whenNotPaused {
       buyTokens();
    }//end of function callback
    
    
    function buyTokens() public payable whenNotPaused {
       require(msg.sender != 0x0);
        require(now>=preSaleStartDate);
        require(now<=saleEndDate);
        uint256 tokens = 0;
       
        if (now < preSaleEndDate) {
            //presLe handle
             tokens = (msg.value * (10 ** decimals)) / priceOfTokenPREICO;
             uint bonus = 0;
             if (now < (preSaleStartDate + 7 days)){
                 bonus = 10;
             }else if (now < (preSaleStartDate + 14 days)) {
                 bonus = 5;
             }
            uint bonusTokens = (tokens * bonus) / 100;
            tokens += bonusTokens;
            
        }else if (now > saleStartDate) {
            //here sale start date
            tokens = (msg.value * (10 ** decimals)) / priceOfToken;
        }else {
            revert(); //this revert is between pre sale and sale time gap
        }
        allowed[owner][msg.sender] += tokens;
        transferFrom(owner,msg.sender,tokens);
        amountRaised += msg.value;
        forwardFunds();
    }//end of funciton

    // send ether to the fund collection wallet
  // override to create custom fund forwarding mechanisms
  function forwardFunds() internal {
    walletForBalanace.transfer(msg.value);
  }

       /**
   * @dev called by the owner to extend deadline relative to last deadLine Time,
   * to accept ether and transfer tokens
   */
   function extendDeadline(uint daysToExtend)public onlyOwner {
       saleEndDate = saleEndDate + daysToExtend * 1 days;
   }

}//end of contract
